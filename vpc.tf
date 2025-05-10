module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs              = var.availability_zones
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
  database_subnets = var.database_subnet_cidrs

  create_database_subnet_group = true

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment != "production"
  one_nat_gateway_per_az = var.environment == "production"

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Name        = "${local.name_prefix}-public"
    Environment = var.environment
    Tier        = "Public"
  }

  private_subnet_tags = {
    Name        = "${local.name_prefix}-private"
    Environment = var.environment
    Tier        = "Private"
  }

  database_subnet_tags = {
    Name        = "${local.name_prefix}-database"
    Environment = var.environment
    Tier        = "Database"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}