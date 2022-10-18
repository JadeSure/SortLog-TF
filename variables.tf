variable "bucket_name" {
  default = "sortlog.oldiron666"
  type    = string
}

variable "s3_origin_id"{
  type = string
}

variable "cdn_comment" {
  type = string
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "region" {}
variable "my_ip_address" {}
variable "instance_type" {}
variable "public_key_location" {}