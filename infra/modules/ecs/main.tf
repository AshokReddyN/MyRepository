# ECS Module: main.tf

# CloudWatch Log Group for the ECS service
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/ecs/${var.env_name}/${var.task_family_name_prefix}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-${var.task_family_name_prefix}-logs"
    }
  )
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.env_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-cluster"
    }
  )
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.task_family_name_prefix}-${var.env_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn # Optional: for app-level AWS permissions

  container_definitions = jsonencode([
    {
      name      = "${var.task_family_name_prefix}-container",
      image     = var.image_uri, # Placeholder like "amazon/amazon-ecs-sample" or actual ECR image
      cpu       = var.app_cpu,
      memory    = var.app_memory,
      essential = true,
      portMappings = [
        {
          containerPort = var.app_port,
          hostPort      = var.app_port # For awsvpc mode, hostPort is often same as containerPort
        }
      ],
      environment = var.environment_variables,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_log_group.name,
          "awslogs-region"        = data.aws_region.current.name, # Assumes region is available via data source
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      "Name" = "${var.task_family_name_prefix}-${var.env_name}-taskdef"
    }
  )
}

# Security Group for ECS Service/Tasks
resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.env_name}-ecs-service-sg"
  description = "Security group for ECS service tasks"
  vpc_id      = var.vpc_id

  # Ingress: Allow traffic from the ALB on the application port
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id] # Only allow from ALB SG
    description     = "Allow traffic from ALB to app container"
  }

  # Egress: Allow all outbound traffic (tasks need to pull images from ECR, talk to MongoDB, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-ecs-service-sg"
    }
  )
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.env_name}-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false # Fargate tasks in private subnets should not have public IPs
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.task_family_name_prefix}-container" # Must match name in container_definitions
    container_port   = var.app_port
  }

  # Ensure tasks are replaced if the task definition changes
  force_new_deployment = true

  # Optional: Deployment circuit breaker
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Optional: Service discovery (not explicitly requested but good for microservices)

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-app-service"
    }
  )

  # Depends on ALB listener if traffic should immediately flow
  # depends_on = [module.alb.http_listener_arn] # This dependency might be in the root module
}

data "aws_region" "current" {}
