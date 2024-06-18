terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-654654443071"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"

  }
}

# Make sure you don't use variables in this particular block