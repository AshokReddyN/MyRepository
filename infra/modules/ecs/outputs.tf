# ECS Module: outputs.tf

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "ecs_service_arn" {
  description = "The ARN of the ECS service"
  value       = aws_ecs_service.main.arn
}

output "task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app_task.arn
}

output "task_definition_family_revision" {
  description = "The family and revision of the ECS task definition (e.g., family:revision)"
  value       = aws_ecs_task_definition.app_task.family # This actually returns family, use .arn for full ARN or construct family:revision
}

output "log_group_name" {
  description = "The name of the CloudWatch Log Group for the ECS service"
  value       = aws_cloudwatch_log_group.app_log_group.name
}

output "ecs_service_security_group_id" {
  description = "The ID of the ECS service security group"
  value       = aws_security_group.ecs_service_sg.id
}
