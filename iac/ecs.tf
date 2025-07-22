# create ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# create cloudwatch log group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.project_name}-${var.environment}-td"
  retention_in_days = 7  # Added log retention to manage costs

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-log-group"
  }
}

# create task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project_name}-${var.environment}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.architecture
  }

  # create container definition
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-container"
      image     = "${local.secrets.ecr_registry}/${var.image_name}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      # Health check configuration for the container
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80/health.php || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      environmentFiles = [
        {
          value = "arn:aws:s3:::${var.project_name}-${var.env_file_bucket_name}/${var.env_file_name}"
          type  = "s3"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      # Resource limits for better stability
      memoryReservation = 1024
      
      # Stop timeout
      stopTimeout = 30
    }
  ])

  tags = {
    Name = "${var.project_name}-${var.environment}-td"
  }
}

# create ecs service
resource "aws_ecs_service" "ecs_service" {
  name             = "${var.project_name}-${var.environment}-service"
  launch_type      = "FARGATE"
  cluster          = aws_ecs_cluster.ecs_cluster.id
  task_definition  = aws_ecs_task_definition.ecs_task_definition.arn
  platform_version = "LATEST"
  desired_count    = 2
  
  # Extended grace period for Laravel application startup
  health_check_grace_period_seconds = 300  # Reduced from 960 to 300 (5 minutes is sufficient)

  # Deployment configuration for stability
  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 50
    
    # Circuit breaker for automatic rollback on failed deployments
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

  # Service discovery (optional - uncomment if you need internal service discovery)
  # service_registries {
  #   registry_arn = aws_service_discovery_service.app_service.arn
  # }

  # Lifecycle management
  lifecycle {
    ignore_changes = [desired_count]  # Allows auto-scaling to manage desired count
  }

  # Ensure dependencies are created first
  depends_on = [
    aws_lb_listener.alb_https_listener,
    aws_lb_listener.alb_http_listener,
    aws_iam_role.ecs_task_execution_role
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-service"
  }
}