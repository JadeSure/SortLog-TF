# terraform {
#   required_version = ">=0.12"
#   backend "s3" {
#     encrypt = true
#     bucket = "oliterraform-bucket"
#     key = "oliterraform/state.tfstate"
#     region = "ap-southeast-2"
#     profile = "default"
#     dynamodb_table = "terraform-state-lock-dynamodb"
#   }
# }