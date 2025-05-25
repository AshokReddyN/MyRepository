variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "env_name" {
  description = "Environment name (e.g., dev, qa, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "List of Availability Zones to use. Should match the number of subnets."
  type        = list(string)
  # These should be dynamically determined or ensured they match the region and count of subnets.
  # For simplicity, using fixed values. Ensure these are valid for your chosen region.
  # Slicing based on data.aws_availability_zones.available.names will be used in module.
  # default     = ["us-east-1a", "us-east-1b"] # This default is not strictly necessary if using data source
}

variable "ecr_repo_name" {
  description = "Name for the ECR repository"
  type        = string
  default     = "user-management-service"
}

variable "app_cpu" {
  description = "CPU units for the ECS task (e.g., 256, 512, 1024)"
  type        = number
  default     = 1024 # 1 vCPU
}

variable "app_memory" {
  description = "Memory in MiB for the ECS task (e.g., 512, 1024, 2048)"
  type        = number
  default     = 2048 # 2GB
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Desired number of tasks for the ECS service"
  type        = number
  default     = 1 # Start with 1 for dev, can be increased for other envs
}

variable "alb_health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/actuator/health" # Spring Boot Actuator health endpoint
}

variable "mongodb_uri_placeholder" {
  description = "Placeholder for MongoDB URI (will be passed as environment variable to ECS)"
  type        = string
  default     = "mongodb://your-mongo-host:27017/user_management_dev_tf_placeholder"
  sensitive   = true
}

variable "jwt_secret_placeholder" {
  description = "Placeholder for JWT Secret (will be passed as environment variable to ECS)"
  type        = string
  default     = "your-jwt-secret-tf-placeholder"
  sensitive   = true
}

variable "fast2sms_api_key_placeholder" {
  description = "Placeholder for Fast2SMS API Key (will be passed as environment variable to ECS)"
  type        = string
  default     = "your-fast2sms-api-key-tf-placeholder"
  sensitive   = true
}

variable "fast2sms_api_url_placeholder" {
  description = "Placeholder for Fast2SMS API URL (will be passed as environment variable to ECS)"
  type        = string
  default     = "https://www.fast2sms.com/dev/bulkV2-tf-placeholder"
  sensitive   = true
}

variable "task_family_name_prefix" {
  description = "Prefix for the ECS task definition family name. Env name will be appended."
  type        = string
  default     = "user-management-app"
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group."
  type        = number
  default     = 7 # Common default for dev environments
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "image_uri" {
  description = "The full URI of the Docker image to deploy (e.g., from ECR). This will be overridden by CI."
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default for standalone Terraform runs or if not provided by CI
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
