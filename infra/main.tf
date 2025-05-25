# Root main.tf

# Data source to get available AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Merge default tags with environment-specific tags
locals {
  common_tags = merge(
    var.tags,
    {
      "Environment" = var.env_name
      "Project"     = "UserManagementService"
    }
  )
}

module "vpc" {
  source = "./modules/vpc"

  env_name             = var.env_name
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  # Use a slice of the available AZs, ensuring we don't request more than available
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, min(length(var.public_subnet_cidrs), length(data.aws_availability_zones.available.names)))
  tags                 = local.common_tags
}

module "ecr" {
  source = "./modules/ecr"

  ecr_repo_name = var.ecr_repo_name
  env_name      = var.env_name
  tags          = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  env_name = var.env_name
  tags     = local.common_tags
}

module "alb" {
  source = "./modules/alb"

  env_name              = var.env_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  app_port              = var.app_port
  health_check_path     = var.alb_health_check_path
  tags                  = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  env_name                       = var.env_name
  vpc_id                         = module.vpc.vpc_id # Needed for security group rules
  private_subnet_ids             = module.vpc.private_subnet_ids
  ecs_task_execution_role_arn    = module.iam.ecs_task_execution_role_arn
  # Use a placeholder image for now. In a real pipeline, this would be the ECR image URI.
  image_uri                      = "${module.ecr.repository_url}:latest" # Or a placeholder like "amazon/amazon-ecs-sample"
  app_cpu                        = var.app_cpu
  app_memory                     = var.app_memory
  app_port                       = var.app_port
  desired_count                  = var.desired_count
  alb_target_group_arn           = module.alb.target_group_arn
  alb_security_group_id          = module.alb.alb_security_group_id # For ECS SG ingress
  task_family_name_prefix        = var.task_family_name_prefix
  log_retention_in_days          = var.log_retention_in_days
  tags                           = local.common_tags

  # Pass placeholders for sensitive data as environment variables
  environment_variables = [
    { name = "SPRING_PROFILES_ACTIVE", value = var.env_name }, # e.g., "dev"
    { name = "SERVER_PORT", value = tostring(var.app_port) },
    { name = "MONGODB_URI", value = var.mongodb_uri_placeholder },
    { name = "JWT_SECRET", value = var.jwt_secret_placeholder },
    { name = "FAST2SMS_API_KEY", value = var.fast2sms_api_key_placeholder },
    { name = "FAST2SMS_API_URL", value = var.fast2sms_api_url_placeholder }
  ]
}
