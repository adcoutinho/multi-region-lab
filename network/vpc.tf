module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 2, k + 1)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 6, k + 1)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]

  enable_nat_gateway                     = true
  single_nat_gateway                     = true
  one_nat_gateway_per_az                 = false
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  enable_vpn_gateway                     = false

  tags                 = merge(local.tags, { Name = local.name })
  private_subnet_tags  = merge(local.tags, { Name = "Computing Subnet in ${local.region}", "karpenter.sh/discovery" = "cluster-eks-${local.name}" })
  database_subnet_tags = merge(local.tags, { Name = "Database Subnet in ${local.region}" })
  public_subnet_tags   = merge(local.tags, { Name = "Public Subnet in ${local.region}" })
}
