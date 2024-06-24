# Data block to fetch the most recent Amazon Linux 2 AMI
data "aws_ami" "example" {
  most_recent = true       # Ensures the most recent AMI is fetched
  owners      = ["amazon"] # AMIs owned by Amazon

  # Filters AMIs by name pattern
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  # Filters AMIs that use EBS as the root device type
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  # Filters AMIs that use hardware virtualization
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data block to fetch all available AWS availability zones
data "aws_availability_zones" "available" {}
