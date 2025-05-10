resource "random_pet" "suffix" {
  length    = 2
  separator = "-"
}

locals {
  name_prefix   = var.name_prefix != "" ? var.name_prefix : "${var.environment}-${random_pet.suffix.id}"
  ubuntu_latest = data.aws_ami.ubuntu.id
  bastion_ami   = var.bastion_ami_id != "" ? var.bastion_ami_id : local.ubuntu_latest
  webapp_ami    = var.webapp_ami_id != "" ? var.webapp_ami_id : local.ubuntu_latest
}

// Fetch latest Ubuntu 24.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}