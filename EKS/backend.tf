terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-851725635917"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}