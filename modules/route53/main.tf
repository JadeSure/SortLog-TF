resource "aws_route53_zone" "hosted_zone" {
  name = "shawnwong.click"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "sortlog.shawnwong.click"
  type    = "A"
  ttl     = 300
  records = [aws_eip.lb.public_ip]
}
