# create ecs service
resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.project_name}-${var.environment}-service"
  launch_type                        = "FARGATE"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  platform_version                   = "LATEST"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300  # Reduced from 960 to 300 (5 minutes)

  # Deployment configuration for circuit breaker
  deployment_configuration {
    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }

  # task tagging configuration
  enable_ecs_managed_tags = false
  propagate_tags          = "SERVICE"

  # vpc and security groups
  network_configuration {
    subnets          = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
    security_groups  = [aws_security_group.app_server_security_group.id]
    assign_public_ip = false
  }

  # load balancing
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "${var.project_name}-${var.environment}-container"
    container_port   = 80
  }

  # Lifecycle management
  lifecycle {
    ignore_changes = [desired_count]
  }

  # Ensure dependencies are created first
  depends_on = [
    aws_lb_listener.alb_https_listener,
    aws_lb_listener.alb_http_listener
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-service"
  }
}