resource "aws_ecr_repository" "main" {
  name = "${var.env_prefix}-sortlog"
  #   This is necessary in order to put a latest tag on the most recent image.
  image_tag_mutability = "MUTABLE"
}


data "aws_ecr_repository" "service" {
  name = "worked-sortlog"
}


resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name


  // more than 10 images, which will be deleted directly
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}