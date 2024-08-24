locals {
  context = {
    lab-use1 = {
      name   = "lab-use1"
      region = "us-east-1"
      cidr   = "10.24.0.0/18"

      tags = {
        Environment = "lab"
        Terraform   = "true"
        Author      = "adcoutinho"
      }
    }
    lab-use2 = {
      name   = "lab-use2"
      region = "us-east-2"
      cidr   = "10.48.0.0/18"

      tags = {
        Environment = "lab"
        Terraform   = "true"
        Author      = "adcoutinho"
      }
    }
  }

  name   = local.context[terraform.workspace].name
  region = local.context[terraform.workspace].region
  cidr   = local.context[terraform.workspace].cidr
  azs    = slice(data.aws_availability_zones.available.names, 0, 3)
  tags   = local.context[terraform.workspace].tags
}
