terraform {

  cloud {
    organization = "jacobbuckles-org"
    workspaces {
      name = "tfc-cv-search"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}

provider "aws" {
  region = "us-west-2"
}

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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*20*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.subnet_id
  vpc_security_group_ids      = [module.vpc.vpc_security_group_id]
  associate_public_ip_address = true

  tags = local.tags
}


