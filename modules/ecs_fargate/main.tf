locals {
  application_name = "${var.env_prefix}-cluster"
  # application_name = "myapp-cluster"
  launch_type = "FARGATE"
}

resource "aws_ecs_cluster" "test-cluster" {
  name = local.application_name
}

resource "aws_ecs_task_definition" "test-def" {
  family                   = "${var.env_prefix}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["${local.launch_type}"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory

  container_definitions = jsonencode([{
    name = "${var.env_prefix}-container"
    # image     = "public.ecr.aws/w2j2c5k5/youtube-local:latest"
    # image     = var.image_link
    image = "${data.aws_ecr_repository.service.repository_url}:latest"
    essential = true
    # environment = [
    #   { "name" : var.sortlog_mongodb_key, "value" : var.sortlog_mongodb_value },
    #   { "name" : var.sortlog_secret_key, "value" : var.sortlog_secret_value },
    #   { "name" : var.sortlog_port_key, "value" : var.sortlog_port_value }
    # ]
    #  environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])
}



resource "aws_ecs_service" "test-service" {
  name            = "${var.env_prefix}-service"
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.test-def.arn

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  desired_count                      = var.app_count

  launch_type         = local.launch_type
  scheduling_strategy = "REPLICA"


  network_configuration {
    security_groups  = [var.ecs_sg.id]
    subnets          = var.private_subnet.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group.arn
    container_name   = "${var.env_prefix}-container"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  depends_on = [var.aws_alb_listener, aws_iam_role_policy_attachment.ecs-task-execution-role-policy-attachment]
}