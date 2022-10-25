output "aws_alb_target_group"{
    value = aws_lb_target_group.back_tg
}

output "aws_alb_listener" {
    value = aws_lb_listener.front_end_listener
}

output "ecs_sg" {
    value = aws_security_group.ecs_sg
}

output "aws_lb"{
    value = aws_lb.back_lb
}

