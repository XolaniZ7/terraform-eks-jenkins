# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"                # Name of the VPC
  cidr = var.vpc_cidr                 # CIDR block for the VPC

  azs             = data.aws_availability_zones.available.names  # Availability zones for the subnets
  private_subnets = var.private_subnets  # CIDR blocks for the private subnets
  public_subnets  = var.public_subnets   # CIDR blocks for the public subnets

  enable_dns_hostnames = true          # Enable DNS hostnames in the VPC
  enable_nat_gateway   = true          # Enable NAT Gateway for private subnets
  single_nat_gateway   = true          # Use a single NAT Gateway

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"  # Tag for EKS cluster shared resources
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"  # Tag for EKS cluster shared resources in public subnets
    "kubernetes.io/role/elb"               = 1         # Tag to identify public subnets for ELBs
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"  # Tag for EKS cluster shared resources in private subnets
    "kubernetes.io/role/internal-elb"      = 1         # Tag to identify private subnets for internal ELBs
  }
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_endpoint_public_access = true  # Enable public access to the EKS cluster endpoint

  cluster_name    = "my-eks-cluster"     # Name of the EKS cluster
  cluster_version = "1.29"               # Version of the EKS cluster

  vpc_id     = module.vpc.vpc_id         # VPC ID for the EKS cluster
  subnet_ids = module.vpc.private_subnets  # Subnet IDs for the EKS cluster nodes

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    nodes = {
      min_size     = 1                  # Minimum number of nodes
      max_size     = 3                  # Maximum number of nodes
      desired_size = 2                  # Desired number of nodes

      instance_types = ["t2.small"]     # EC2 instance types for the nodes
    }
  }

  tags = {
    Environment = "dev"                 # Environment tag
    Terraform   = "true"                # Tag indicating it's managed by Terraform
  }
}
