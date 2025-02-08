# AWS Account ID (used for ECR image)
variable "aws_account_id" {
  description = "AWS Account ID for ECR"
  type        = string
}

# AWS Region
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}


# Database Variables
variable "db_host" {
  description = "RDS PostgreSQL endpoint"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "logs"
}

variable "db_port" {
  description = "Database port"
  default     = "5432"
}

variable "port" {
  description = "Application port"
  default     = 3000

}