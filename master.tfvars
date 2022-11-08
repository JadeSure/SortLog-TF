region         = "ap-southeast-2"
aws_profile    = "default"
acm_region     = "us-east-1"
bucket_name    = "oldiron666.sortlog"
s3_origin_id   = "oldiron666"
cdn_comment    = "sortlog cdn"
my_domain_name = "sortlog.net"
env_prefix     = "uat"
exist_repo     = "worked-sortlog"

# VPC
vpc_cidr_block = "10.123.0.0/16"
# public_subnet_cidr_block  = "10.0.10.0/24"
# private_subnet_cidr_block = "10.0.1.0/24"
avail_zone       = "ap-southeast-2a"
az_private_count = 2
az_public_count  = 2

# EC2
my_ip_address       = "60.242.208.47/32"
instance_type       = "t2.micro"
public_key_location = "~/.ssh/id_rsa.pub"

# ALB
health_check_path = "/health-check"

# ecs
# desired task count
app_count                = 2
container_port           = 4000
fargate_cpu              = 512
fargate_memory           = 1024
api_domain_name          = "api.sortlog.net"
# sortlog_api_image_link   = "003374733998.dkr.ecr.ap-southeast-2.amazonaws.com/dev-sortlog:latest"
sortlog_api_max_capacity = 4
sortlog_api_min_capacity = 1

# lambda
lambda_bucket = "sortlog.lambda"

# grafana
grafana_app_count            = 1
grafana_container_port       = 4000
sortlog_grafana_min_capacity = 1
sortlog_grafana_max_capacity = 2
grafana_domain_name          = "grafana.devops.shawnwong.click"
grafana_image_link           = "grafana/grafana:latest"

