//Instance SPOT, NGINX, ACL AWS
resource "aws_security_group" "compute_sg" {
  name        = "compute-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.compute_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
//   cidr_blocks = ["0.0.0.0/0"]
  }

  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
  description     = "HTTP from ALB"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  security_groups = [var.alb_security_group_id]
}








  tags = var.compute_tags
}

//Instancia

resource "aws_instance" "compute_spot" {
  ami                    = data.aws_ami.compute_amazon_linux.id
  iam_instance_profile = aws_iam_instance_profile.ec2_static_profile.name
  instance_type          = var.compute_instance_type
  subnet_id              = var.compute_public_subnet_id
  availability_zone      = var.compute_az
  vpc_security_group_ids = [aws_security_group.compute_sg.id]
  key_name               = aws_key_pair.compute_key.key_name
  




  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y awscli

  amazon-linux-extras install nginx1 -y
  systemctl enable nginx
  systemctl start nginx

  mkdir -p /usr/share/nginx/html

  # Script de sincronización
  cat <<'SYNC' > /usr/local/bin/s3-sync.sh
  #!/bin/bash
  aws s3 sync s3://${var.static_s3_bucket_name} /usr/share/nginx/html --delete
  SYNC

  chmod +x /usr/local/bin/s3-sync.sh

  # Servicio systemd
  cat <<'SERVICE' > /etc/systemd/system/s3-sync.service
  [Unit]
  Description=Sync S3 static site to NGINX
  After=network.target

  [Service]
  Type=oneshot
  ExecStart=/usr/local/bin/s3-sync.sh
  SERVICE

  # Timer systemd (cada 5 minutos)
  cat <<'TIMER' > /etc/systemd/system/s3-sync.timer
  [Unit]
  Description=Run S3 sync every 5 minutes

  [Timer]
  OnBootSec=1min
  OnUnitActiveSec=5min
  Persistent=true

  [Install]
  WantedBy=timers.target
  TIMER

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable s3-sync.timer
  systemctl start s3-sync.timer
EOF

  tags = merge(
    {
      Name = "compute-spot-web"
    },
    var.compute_tags
  )
}

//AMI

data "aws_ami" "compute_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

//KeyPair



resource "aws_key_pair" "compute_key" {
  key_name   = var.compute_key_name
  public_key = tls_private_key.compute_ssh.public_key_openssh
}

resource "tls_private_key" "compute_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



output "compute_private_key_pem" {
  value     = tls_private_key.compute_ssh.private_key_pem
  sensitive = true
}

//Llamada a ALB

variable "alb_target_group_arn" {
  type = string
}


//Añadir target group a EC2

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.alb_target_group_arn
  target_id        = aws_instance.compute_spot.id
  port             = 80
}

