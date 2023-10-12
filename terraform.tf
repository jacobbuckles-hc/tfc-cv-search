terraform {

  cloud {
    organization = ""
    workspaces {
      name = ""
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