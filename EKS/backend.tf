terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-767397690733"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}