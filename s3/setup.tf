provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "use2"
  region = "us-east-2"
}

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.6"
    }
  }
}