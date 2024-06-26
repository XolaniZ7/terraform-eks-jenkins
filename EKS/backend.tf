terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-975050055337"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

  }
}