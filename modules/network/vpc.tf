locals {
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  count = var.create_vpc ? 1 : 0 
  source = "terraform-aws-modules/vpc/aws"
  version = var.vpc_module_version

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 2, k + 1)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 6, k + 1)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]

  enable_nat_gateway                     = true
  single_nat_gateway                     = true
  one_nat_gateway_per_az                 = false
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  enable_vpn_gateway                     = false

  tags                 = merge(var.vpc_tags, { Name = var.vpc_name })
  private_subnet_tags  = merge(var.vpc_tags, { Name = "Computing Subnet in ${var.region}", "karpenter.sh/discovery" = "cluster-eks-${var.vpc_name}" })
  database_subnet_tags = merge(var.vpc_tags, { Name = "Database Subnet in ${var.region}" })
  public_subnet_tags   = merge(var.vpc_tags, { Name = "Public Subnet in ${var.region}" })
}
