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

variable "region" {}
variable "my_domain_name" {}
variable "acm_region" {}

variable "vpc_cidr_block" {}
variable "public_subnet_cidr_block" {}
variable "private_subnet_cidr_block" {}
variable "env_prefix" {}
variable "avail_zone" {}

variable "public_key_location" {}
variable "my_ip_address" {}
variable "instance_type" {}

