terraform {
  required_version = ">=0.12"
  backend "s3" {
    encrypt = true
    bucket = "sortlog-tf-1-11-2022"
    key = "./terraform.tfstate"
    region = "ap-southeast-2"
    profile = "default"
    dynamodb_table = "terraform-state-lock-sortlog"
  }
}