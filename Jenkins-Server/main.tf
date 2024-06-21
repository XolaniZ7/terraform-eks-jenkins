# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"                # Name of the VPC
  cidr = var.vpc_cidr                 # CIDR block for the VPC

  azs            = data.aws_availability_zones.available.names  # Availability zones for the subnets
  public_subnets = var.public_subnets  # CIDR blocks for the public subnets

  enable_dns_hostnames = true         # Enable DNS hostnames in the VPC

  tags = {
    name        = "jenkins-vpc"       # Name tag for the VPC
    Terraform   = "true"              # Tag indicating it's managed by Terraform
    Environment = "dev"               # Environment tag
  }

  public_subnet_tags = {
    name = "jenkins subnet"           # Name tag for the public subnets
  }
}

# Security Group for Jenkins
module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"          # Name of the security group
  description = "Security group for Jenkins"  # Description of the security group
  vpc_id      = module.vpc.vpc_id     # VPC ID for the security group

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"            # Allow HTTP traffic on port 8080
      cidr_blocks = "0.0.0.0/0"       # Source CIDR block
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"             # Allow SSH traffic on port 22
      cidr_blocks = "0.0.0.0/0"       # Source CIDR block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"              # Allow all outbound traffic
      cidr_blocks = "0.0.0.0/0"       # Destination CIDR block
    }
  ]

  tags = {
    name = "jenkins-sg"               # Name tag for the security group
  }
}

# EC2 Instance for Jenkins
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-server"             # Name of the EC2 instance

  instance_type               = var.instance_type               # EC2 instance type
  key_name                    = "jenkins-kp"                    # Key pair name for SSH access
  monitoring                  = true                            # Enable detailed monitoring
  vpc_security_group_ids      = [module.vote_service_sg.security_group_id]  # Security group for the instance
  subnet_id                   = module.vpc.public_subnets[0]    # Subnet ID for the instance
  associate_public_ip_address = true                            # Assign a public IP address
  user_data                   = file("jenkins-install.sh")      # User data script for installing Jenkins
  availability_zone           = data.aws_availability_zones.available.names[0]  # Availability zone for the instance

  tags = {
    name        = "jenkins-server"    # Name tag for the EC2 instance
    Terraform   = "true"              # Tag indicating it's managed by Terraform
    Environment = "dev"               # Environment tag
  }
}
