locals {
  bucket_name = "multiregion-lab"

  tags = {
    Environment = "lab"
    Terraform   = "true"
    Name        = "multiregion-lab"
    Author      = "adcoutinho"
  }
}
