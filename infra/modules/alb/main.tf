# ALB Module: main.tf

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "${var.env_name}-alb-sg"
  description = "Security group for ALB, allows HTTP/HTTPS inbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443 # If you plan to use HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-alb-sg"
    }
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.env_name}-app-alb"
  internal           = false # Internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids # ALB needs to be in public subnets

  enable_deletion_protection = false # Set to true for production

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-app-alb"
    }
  )
}

# Target Group for the application
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.env_name}-app-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # For Fargate tasks

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port" # Checks on the port the target group is configured for
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30 # Seconds
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-app-tg"
    }
  )
}

# Listener for HTTP traffic on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-http-listener"
    }
  )
}

# Optional: Listener for HTTPS on port 443 (requires ACM certificate)
/*
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Choose an appropriate policy
  certificate_arn   = "arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERTIFICATE_ID" # Replace with your ACM cert ARN

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-https-listener"
    }
  )
}
*/
