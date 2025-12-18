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
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = var.compute_tags
}

//Instancia

resource "aws_instance" "compute_spot" {
  ami                    = data.aws_ami.compute_amazon_linux.id
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
    systemctl start nginx
    systemctl enable nginx

    echo "<h1>Terraform Web Server</h1>" > /usr/share/nginx/html/index.html
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

