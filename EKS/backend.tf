terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-590183997723"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}