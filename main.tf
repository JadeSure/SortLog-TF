module "front-s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  s3_policy   = data.aws_iam_policy_document.s3_policy.json
}

module "front-cdn" {
  source          = "./modules/cdn"
  s3_origin_id    = var.s3_origin_id
  domain_name     = module.front-s3.s3_bucket.bucket_regional_domain_name
  cdn_comment     = var.cdn_comment
  my_domain_name  = var.my_domain_name
  acm_certificate = module.front-acm.acm_certificate
}


# for OAI updating policy
# Generates an IAM policy document in JSON format for use with resources that expect policy documents
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    # resources = ["${aws_s3_bucket.deploy_bucket.arn}/*"]
    resources = ["${module.front-s3.s3_bucket.arn}/*"]

    principals {
      type = "AWS"
      #   identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oia.iam_arn]
      identifiers = [module.front-cdn.cloudfront_oia.iam_arn]
    }
  }
}

module "front-acm" {
  source         = "./modules/acm"
  my_domain_name = var.my_domain_name
  acm_region     = var.acm_region
}


module "front-route53" {
  source                  = "./modules/route53"
  acm_certificate         = module.front-acm.acm_certificate
  my_domain_name          = var.my_domain_name
  acm_region              = var.acm_region
  cloudfront_distribution = module.front-cdn.cloudfront_distribution
}


module "back-vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  env_prefix     = var.env_prefix
  # public_subnet_cidr_block  = var.public_subnet_cidr_block
  # private_subnet_cidr_block = var.private_subnet_cidr_block
  az_private_count = var.az_private_count
  az_public_count  = var.az_public_count
  avail_zone       = var.avail_zone
}


module "myapp-server" {
  source = "./modules/ec2"

  vpc_id              = module.back-vpc.myapp_vpc.id
  my_ip_address       = var.my_ip_address
  env_prefix          = var.env_prefix
  instance_type       = var.instance_type
  avail_zone          = var.avail_zone
  public_key_location = var.public_key_location
  # because I used count skills in vpc, I need to specific which public subnet to create
  subnet_id      = module.back-vpc.public_subnet[0].id
  route_table_id = module.back-vpc.public_route_table[0].id
}


module "back-elb" {
  source              = "./modules/elb"
  health_check_path   = var.health_check_path
  my_domain_name      = var.my_domain_name
  acm_region          = var.acm_region
  container_port      = var.container_port
  public_subnet       = module.back-vpc.public_subnet
  myapp_vpc           = module.back-vpc.myapp_vpc
  acm_certificate_sdy = module.front-acm.acm_certificate_sdy
}

module "ecs-fargate" {
  source          = "./modules/ecs_fargate"
  app_count       = var.app_count
  env_prefix      = var.env_prefix
  container_port  = var.container_port
  fargate_cpu     = var.fargate_cpu
  fargate_memory  = var.fargate_memory
  api_domain_name = var.api_domain_name
  my_domain_name  = var.my_domain_name
  # image_link      = var.sortlog_api_image_link
  exist_repo = var.exist_repo

  max_capacity    = var.sortlog_api_max_capacity
  min_capacity    = var.sortlog_api_min_capacity

  aws_lb               = module.back-elb.aws_lb
  ecs_sg               = module.back-elb.ecs_sg
  private_subnet       = module.back-vpc.private_subnet
  aws_alb_target_group = module.back-elb.aws_alb_target_group
  aws_alb_listener     = module.back-elb.aws_alb_listener

  # sortlog_mongodb_key = var.sortlog_mongodb_key
  # sortlog_secret_key  = var.sortlog_secret_key
  # sortlog_port_key    = var.sortlog_port_key

  # sortlog_mongodb_value = var.sortlog_mongodb_value
  # sortlog_secret_value  = var.sortlog_secret_value
  # sortlog_port_value    = var.sortlog_port_value
}


# module "grafana-elb" {
#   source              = "./modules/elb"
#   health_check_path   = var.health_check_path
#   my_domain_name      = var.my_domain_name
#   acm_region          = var.acm_region
#   container_port      = var.container_port
#   public_subnet       = module.back-vpc.public_subnet
#   myapp_vpc           = module.back-vpc.myapp_vpc
#   acm_certificate_sdy = module.front-acm.acm_certificate_sdy
# }


# module "ecs-grafana" {
#   source = "./modules/ecs_fargate"
#   app_count = var.grafana_app_count
#   env_prefix          = var.env_prefix
#   container_port = var.grafana_container_port
#   fargate_cpu = var.fargate_cpu
#   fargate_memory = var.fargate_memory
#   api_domain_name = var.grafana_domain_name
#   my_domain_name = var.my_domain_name
#   image_link = var.grafana_image_link
#   max_capacity = var.sortlog_grafana_max_capacity
#   min_capacity = var.sortlog_grafana_min_capacity

#   aws_lb = module.grafana-elb.aws_lb
#   ecs_sg               = module.grafana-elb.ecs_sg
#   private_subnet       = module.back-vpc.private_subnet
#   aws_alb_target_group = module.grafana-elb.aws_alb_target_group
#   aws_alb_listener     = module.grafana-elb.aws_alb_listener

# }


# for lambda + api gateway
# module "back-lambda" {
#   source        = "./modules/lambda"
#   lambda_bucket = var.lambda_bucket
# }