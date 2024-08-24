locals {
  role = {
    argo = {
      name = "argo"
    }
  }
  user = {}
  irsa = {}

  tags = {
    Environment = "lab"
    Terraform   = "true"
    Name        = "multiregion-lab"
    Author      = "adcoutinho"
  }
}
