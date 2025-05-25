variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC for security group rules"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ECS tasks"
  type        = list(string)
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution IAM Role"
  type        = string
}

variable "image_uri" {
  description = "URI of the Docker image in ECR (e.g., account_id.dkr.ecr.region.amazonaws.com/repo_name:tag)"
  type        = string
  default     = "amazon/amazon-ecs-sample" # Default to a sample image for initial setup
}

variable "app_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "app_memory" {
  description = "Memory in MiB for the ECS task"
  type        = number
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
}

variable "desired_count" {
  description = "Desired number of tasks for the ECS service"
  type        = number
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB Target Group to associate with the service"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB's security group for ECS SG ingress rule"
  type        = string
}

variable "task_family_name_prefix" {
  description = "Prefix for the ECS task definition family name. Env name will be appended."
  type        = string
}

variable "log_retention_in_days" {
  description = "Specifies the number of days to retain log events in the CloudWatch Log Group."
  type        = number
  default     = 7
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "List of environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Optional: Task Role ARN if your application needs to interact with other AWS services
variable "ecs_task_role_arn" {
  description = "Optional: ARN of the ECS Task IAM Role (for application-level AWS permissions)"
  type        = string
  default     = null # No task role by default
}
