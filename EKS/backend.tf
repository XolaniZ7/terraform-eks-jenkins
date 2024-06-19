terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-381491917071"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}