# how many fargate would be available
variable "app_count" {}

variable "env_prefix" {}
variable "container_port" {}
variable "fargate_cpu"{}
variable "fargate_memory"{}
# variable "container_environment" {}

variable "private_subnet" {}
variable "aws_alb_target_group" {}
variable "aws_alb_listener" {}
variable "ecs_sg"{}

variable "api_domain_name" {}
variable "aws_lb" {}
variable "my_domain_name" {}