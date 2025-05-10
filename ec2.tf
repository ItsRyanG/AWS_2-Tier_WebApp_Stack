// Bastion host EC2 instance
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-bastion"

  ami                         = local.bastion_ami
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    }
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

// Web application EC2 instance
module "webapp" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-webapp"

  ami                         = local.webapp_ami
  instance_type               = var.webapp_instance_type
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.webapp_sg.security_group_id]
  subnet_id                   = module.vpc.private_subnets[0]
  user_data                   = data.template_file.user_data.rendered
  associate_public_ip_address = false
  iam_instance_profile        = module.webapp_role.iam_instance_profile_name

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    }
  ]

  tags = {
    Name        = "${local.name_prefix}-webapp"
    Environment = var.environment
    Terraform   = "true"
  }
  depends_on = [
    aws_secretsmanager_secret_version.db_credentials,
    module.vpc
  ]
}

// template for web application EC2 instance user data
data "template_file" "user_data" {
  template = file("${path.module}/scripts/webapp_init.sh.tpl")

  vars = {
    aws_region = var.aws_region
    db_host    = module.db.db_instance_address
    secret_id  = aws_secretsmanager_secret.db_credentials.id
  }
}