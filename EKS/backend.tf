terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-891377368990"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}