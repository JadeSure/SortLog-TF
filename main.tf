provider "aws" {
  region = var.region
}


module "front-s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  s3_policy   = data.aws_iam_policy_document.s3_policy.json
}

module "front-cdn" {
  source       = "./modules/cdn"
  s3_origin_id = var.s3_origin_id
  domain_name  = module.front-s3.s3_bucket.bucket_regional_domain_name
  cdn_comment  = var.cdn_comment
  my_domain_name = var.my_domain_name
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
  source           = "./modules/acm"
  my_domain_name   = var.my_domain_name
  acm_region       = var.acm_region
}


module "front-route53" {
  source           = "./modules/route53"
  acm_certificate  = module.front-acm.acm_certificate
  my_domain_name   = var.my_domain_name
  acm_region       = var.acm_region
  cloudfront_distribution = module.front-cdn.cloudfront_distribution
}


module "myapp-subnet" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  env_prefix = var.env_prefix

  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block

  avail_zone = var.avail_zone
}



# module "myapp-server"{
#   source = "./modules/ec2"

#   vpc_id = aws_vpc.myapp-vpc.id
#   my_ip_address = var.my_ip_address
#   env_prefix = var.env_prefix
#   instance_type = var.instance_type
#   avail_zone = var.avail_zone
#   public_key_location = var.public_key_location
#   # subnet_id = module.myapp-subnet.subnet[0].id
#   # route_table_id = module.myapp-subnet.subnet[1].id
#   subnet_id = module.myapp-subnet.oldiron1.id
#   route_table_id = module.myapp-subnet.oldiron2.id
  
# }
