terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-654654443071"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}