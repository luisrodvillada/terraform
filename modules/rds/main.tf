########################
# Security Group RDS
########################

resource "aws_security_group" "rds" {
  name   = "rds-sg-${var.environment}"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

########################
# Allow backend → RDS
########################

resource "aws_security_group_rule" "allow_postgres_from_backend" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"

  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.backend_sg_id

  description = "Allow PostgreSQL from backend ASG"
}

########################
# Subnet group
########################

resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

########################
# RDS PostgreSQL
########################

resource "aws_db_instance" "this" {
  identifier             = "postgres-${var.environment}"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "postgres-rds"
  }
}


resource "aws_security_group_rule" "allow_postgres_from_alb_sg" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"

  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.alb_security_group_id

  description = "Allow PostgreSQL from ALB/EC2 SG"
}
