variable "bucket_name" {
  default = "sortlog.oldiron666"
  type    = string
}

variable "s3_origin_id" {
  type = string
}

variable "cdn_comment" {
  type = string
}

# ACM
variable "region" {}
variable "my_domain_name" {}
variable "acm_region" {}

# VPC
variable "vpc_cidr_block" {}
# variable "public_subnet_cidr_block" {}
# variable "private_subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}
variable "az_private_count" {}
variable "az_public_count" {}

# EC2
variable "public_key_location" {}
variable "my_ip_address" {}
variable "instance_type" {}

# ALB
variable "health_check_path" {}

# ECS
variable "app_count" {}
variable "container_port" {}
variable "fargate_cpu" {}
variable "fargate_memory" {}
variable "api_domain_name" {}
