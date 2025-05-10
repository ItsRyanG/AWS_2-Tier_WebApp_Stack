output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = module.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.bastion.public_ip
}

output "webapp_instance_id" {
  description = "ID of the web application server instance"
  value       = module.webapp.id
}

output "webapp_private_ip" {
  description = "Private IP address of the web application server"
  value       = module.webapp.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.alb.lb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS database"
  value       = module.db.db_instance_endpoint
}

output "rds_database_name" {
  description = "Name of the RDS database"
  value       = module.db.db_instance_name
}

output "rds_username" {
  description = "Username for the RDS database"
  value       = module.db.db_instance_username
  sensitive   = true
}
