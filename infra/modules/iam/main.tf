# IAM Module: main.tf

# ECS Task Execution Role
# This role is used by ECS agents to make AWS API calls on your behalf (e.g., pull ECR images, send logs to CloudWatch).
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.env_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-ecs-task-execution-role"
    }
  )
}

# Attach the standard AmazonECSTaskExecutionRolePolicy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: ECS Task Role (if your application code needs to interact with other AWS services)
# For this user-management service, it's not explicitly stated as needed yet.
# If, for example, it needed to write to S3 or read from DynamoDB directly, you'd define a task role here.
/*
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-ecs-task-role"
    }
  )
}

# Example policy for the task role (e.g., S3 access)
resource "aws_iam_policy" "ecs_task_s3_access" {
  name        = "${var.env_name}-ecs-task-s3-access-policy"
  description = "Policy to allow ECS tasks to access specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::your-bucket-name/*" # Specify your bucket
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      "Name" = "${var.env_name}-ecs-task-s3-access-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_s3_access_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_s3_access.arn
}
*/
