terraform {
  backend "s3" {
    bucket         = "log-api-statefile"  # Replace with your actual S3 bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Use the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get available public subnets in the default VPC
data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow database access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# PostgreSQL RDS Instance
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "postgres"
  engine_version      = "14.14"
  instance_class      = "db.t3.micro"
  identifier          = "log-api-db"
  username           = var.db_user
  password           = var.db_password
  db_name            = var.db_name
  publicly_accessible = true  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az            = false
  skip_final_snapshot = true
}

# Output the RDS Endpoint
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_execution_role_policy" {
  name       = "ecs-execution-role-attach"
  roles      = [aws_iam_role.ecs_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom Policy for CloudWatch Logs
resource "aws_iam_policy" "ecs_logging_policy" {
  name        = "ECSLoggingPolicy"
  description = "Allows ECS Tasks to log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_logging" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_logging_policy.arn
}

# ECS Cluster
resource "aws_ecs_cluster" "log_cluster" {
  name = "log-api-cluster"
}


resource "aws_ecs_task_definition" "log_task" {
  family                   = "log-api-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "log-api"
      image     = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/log-api:latest"
      cpu       = 256
      memory    = 512
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.postgres.endpoint },
        { name = "DB_USER", value = var.db_user },
        { name = "DB_PASS", value = var.db_password },
        { name = "DB_NAME", value = var.db_name },
        { name = "DB_PORT", value = var.db_port },
        { name = "PORT", value = var.port }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/log-api"  # Log Group Name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
          mode                  = "non-blocking"
          max-buffer-size       = "25m"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "log_service" {
  name            = "log-api-service"
  cluster         = aws_ecs_cluster.log_cluster.id
  task_definition = aws_ecs_task_definition.log_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.default_public_subnets.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name   = "log-api-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

