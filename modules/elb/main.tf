provider "aws" {
  region = var.acm_region
  alias  = "Virginia"
}

resource "aws_lb" "back_lb" {
  name               = "ECS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [for subnet in var.public_subnet : subnet.id]

  # enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}


# data "aws_acm_certificate" "issued" {
#   # provider = aws.Virginia
#   domain   = var.my_domain_name
#   statuses = ["ISSUED"]
#   depends_on = [var.acm_certificate_sdy]
# }

resource "aws_lb_target_group" "back_tg" {
  name        = "myecs-tg"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.myapp_vpc.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30
  }
}

# resource "aws_lb_listener_certificate" "listener_certificate" {
#   listener_arn    = aws_lb_listener.front_end_listener.arn
#   certificate_arn = data.aws_acm_certificate.issued.arn
# }

# one for HTTP and one for HTTPS, where the HTTP listener redirects to the HTTPS listener,
#  which funnels traffic to the target group.
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.back_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "front_end_listener" {
  load_balancer_arn = aws_lb.back_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = data.aws_acm_certificate.issued.arn
  certificate_arn = var.acm_certificate_sdy.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_tg.arn
  }
}

