# ECR Module: main.tf

resource "aws_ecr_repository" "main" {
  name                 = var.ecr_repo_name # Set to var.ecr_repo_name
  image_tag_mutability = "MUTABLE"         # Or "IMMUTABLE" if preferred

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      "Name"        = "${var.env_name}-${var.ecr_repo_name}" # More descriptive name
      "Environment" = var.env_name
    }
  )
}

# Optional: ECR Lifecycle Policy to manage images (e.g., keep last N images)
resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
