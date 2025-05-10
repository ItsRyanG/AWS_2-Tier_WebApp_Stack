## Instructions

Use your Infrastructure-as-Code tool of choice, e.g., Terraform, Cloudformation, etc. to
provision the following set of resources in a given AWS account. Make sure you use
best practices, Nested Stacks in Cloudformation, or Modules in Terraform. Note that
in the given setup, incoming traffic on port 22 and port 443 goes to a Bastion host
and an ELB, respectively to be forwarded to the web app server. The outgoing traffic
from the web app server goes to a NAT to be sent to the Internet. Feel free to state
any assumptions implemented against.

## Plan

I will use Terraform community modules from https://github.com/terraform-aws-modules/ instead of writing custom modules to demonstrate a real-world environment where modules already exist. I will provision a single VPC with public, private, and DB subnets. I will create three security groups (bastion, webapp, and database), deploy an RDS MySQL instance, launch a bastion host, configure an Internet-facing ALB with SSL termination using a pre-existing wildcard certificate from AWS Certificate Manager for my own domain, and run a small bootstrap script on the webapp EC2 instance that prints the database version for connectivity validation. Given more time, I would also encrypt traffic between the ALB and the webapp EC2 instance and implement IAM authentication for the RDS database.

- **Networking**  
  - VPC with public, private and DB subnets across two AZs (via `terraform-aws-modules/vpc/aws`)

- **Security Groups**  
  - **bastion-sg**: SSH allow all 
  - **webapp-sg**: HTTP/HTTPS from ALB, SSH from bastion  
  - **db-sg**: MySQL (3306) from webapp only  

- **Compute**  
  - **Bastion Host**: EC2 instance configured with an AWS SSH key pair
  - **Webapp Server**: EC2 instance bootstrapped to print the RDS version

- **Load Balancer**  
  - Internet-facing ALB (`terraform-aws-modules/alb/aws`) on 443 → forwards to webapp on 80  

- **NAT & Routing**  
  - NAT Gateways in public subnets, private subnets routed through them  

- **Database**  
  - RDS MySQL in DB subnets (`terraform-aws-modules/rds/aws`) 

- **Validation**  
  1. SSH → bastion  
  2. `curl http://<ALB_DNS>/` → MySQL version  

