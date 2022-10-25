# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "alb-sg" {
  name        = "sotlog-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = var.myapp_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# this security group for ecs task - Traffic to the ECS cluster should only come from the ALB
# allowing ingress access only to the port that is exposed by the task.
resource "aws_security_group" "ecs_sg" {
  name        = "sotlog-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = var.myapp_vpc.id

  ingress {
    protocol        = "tcp"
    # from_port       = 80
    # to_port         = 80
    from_port = var.container_port
    to_port = var.container_port
    # cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
