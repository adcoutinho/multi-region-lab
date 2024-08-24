terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }

  backend "s3" {
    bucket = "multiregion-lab"
    key    = "aws-multiregion-lab/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = local.region
}
