provider "aws" {
  region = var.region
}

module "front-s3" {
    source = "./modules/s3"
    bucket_name = var.bucket_name
    s3_policy = data.aws_iam_policy_document.s3_policy.json
}

module "front-cdn"{
    source = "./modules/cdn"
    s3_origin_id = var.s3_origin_id
    domain_name = module.front-s3.s3_bucket.bucket_regional_domain_name
    cdn_comment = var.cdn_comment
}


# for OAI updating policy
# Generates an IAM policy document in JSON format for use with resources that expect policy documents
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    # resources = ["${aws_s3_bucket.deploy_bucket.arn}/*"]
    resources = ["${module.front-s3.s3_bucket.arn}/*"]

    principals {
      type        = "AWS"
    #   identifiers = [aws_cloudfront_origin_access_identity.cloudfront_oia.iam_arn]
      identifiers = [module.front-cdn.cloudfront_oia.iam_arn]
    }
  }
}

# # for OAI
# resource "aws_cloudfront_origin_access_identity" "cloudfront_oia" {
#   comment = "example origin access identify"
# }

# locals {
#   s3_origin_id = "sortLogS3Origin"
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = module.front-s3.s3_bucket.bucket_regional_domain_name
#     origin_id   = local.s3_origin_id


#     # for oai
#     s3_origin_config {
#       #  create an aws cloudfront OAI
#       origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_oia.cloudfront_access_identity_path
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "My first CDN"
#   default_root_object = "index.html"

#   #   logging_config {
#   #     include_cookies = false
#   #     bucket          = "mylogs.s3.amazonaws.com"
#   #     prefix          = "myprefix"
#   #   }

#   #   aliases = ["mysite.example.com", "yoursite.example.com"]

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   price_class = "PriceClass_All"

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "AU"]
#     }
#   }

#   tags = {
#     Environment = "production"
#   }

#   # for https
#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }

