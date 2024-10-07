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

locals {
  context_yaml = fileset("${path.module}/environments", "*/${terraform.workspace}.yaml")
  config = { for file in fileset("${path.module}/environments", "*/${terraform.workspace}.yaml") : terraform.workspace => "./environments/${file}" }
}

