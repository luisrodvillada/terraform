resource "aws_security_group" "alb_sg" {
  name        = "${var.alb_name}-sg"
  description = "Allow HTTP from Internet"
  vpc_id      = var.vpc_id

  ingress {
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
}

//Crear ALB
resource "aws_lb" "this" {
  name               = var.alb_name
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb_sg.id]
  subnets         = var.public_subnet_ids
}

//Target group

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.alb_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


//Listener

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

