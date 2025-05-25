variable "env_name" {
  description = "Environment name for tagging and naming resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
