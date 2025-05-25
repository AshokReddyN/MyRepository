variable "ecr_repo_name" {
  description = "Name for the ECR repository"
  type        = string
}

variable "env_name" {
  description = "Environment name for tagging"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
