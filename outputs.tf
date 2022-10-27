# output "website_cdn_id" {
#   #   value = aws_cloudfront_distribution.s3_distribution.id
#   value = module.front-cdn.cloudfront_distribution.id
# }
output "alb_dns_name"{
  value = module.back-elb.aws_lb.dns_name
}

output "cdn" {
  #   value = aws_cloudfront_distribution.s3_distribution.domain_name
  value = module.front-cdn.cloudfront_distribution.domain_name
}


output "back_domain_name" {
  value = var.api_domain_name
}

output "front_domain_name" {
  value = var.my_domain_name
}

output "api_gateway_url" {
  value = module.back-lambda.base_url.invoke_url
}