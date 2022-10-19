output "website_cdn_id" {
  #   value = aws_cloudfront_distribution.s3_distribution.id
  value = module.front-cdn.cloudfront_distribution.id
}

output "website_endpoint" {
  #   value = aws_cloudfront_distribution.s3_distribution.domain_name
  value = module.front-cdn.cloudfront_distribution.domain_name
}

output "my_domain_name" {
  value = var.my_domain_name
}