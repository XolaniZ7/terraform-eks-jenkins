terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-533267054305"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}