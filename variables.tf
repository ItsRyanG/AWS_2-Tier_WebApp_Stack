variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Optional override for naming prefix. If empty, default to env-pet suffix."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "webapp_instance_type" {
  description = "Instance type for the web application servers"
  type        = string
  default     = "t3.small"
}

variable "webapp_ami_id" {
  description = "AMI ID for the web application servers"
  type        = string
  default     = "ami-084568db4383264d4" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
}

variable "bastion_ami_id" {
  description = "AMI ID for the bastion servers"
  type        = string
  default     = "ami-084568db4383264d4" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type

}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "my-key-pair"
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "webapp_db"
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  default     = "password123" # Change this to a secure password
  sensitive   = true
}

variable "certificate_arn" {
  description = "ARN for the SSL certificate"
  type        = string
  default     = ""
}