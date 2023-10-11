terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.23.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}

provider "aws" {
  region = "us-east-2"
}

provider "hcp" {}

locals {
  tags = {
    Name = "My Demo App CV Check"
    ManagedBy = "Terraform"
  }
}

module "vpc" {
  source  = "app.terraform.io/jacobbuckles-org/vpc/aws"
  version = "0.0.2"

  cidr_vpc = "10.1.0.0/16"
  cidr_subnet = "10.1.0.0/24"
  tags = local.tags
}

data "hcp_packer_iteration" "ubuntu" {
  bucket_name = "packer-demo"
  channel     = "development"
}

data "hcp_packer_image" "ubuntu_us_east_2" {
  bucket_name    = "packer-demo"
  cloud_provider = "aws"
  iteration_id   = data.hcp_packer_iteration.ubuntu.ulid
  region         = "us-east-2"
}

resource "aws_instance" "web" {
  ami                         = data.hcp_packer_image.ubuntu_us_east_2.cloud_image_id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.subnet_id
  vpc_security_group_ids      = [module.vpc.vpc_security_group_id]
  associate_public_ip_address = true

  tags = local.tags
}
