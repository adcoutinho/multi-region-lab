locals {

  partition          = data.aws_partition.current.partition
  account_id         = data.aws_caller_identity.current.account_id
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnets
  service_cidr       = "10.176.0.0/20"

  context = {
    lab-use1 = {
      name              = "cluster-eks-lab-use1"
      region            = "us-east-1"
      version           = "1.30"
      capacity_type     = "SPOT"
      desired_nodes     = 2

      # Karpenter options
      karpenter_config = {
        controller_version = "0.37.0"
      }
      
      # Cilium options
      cilium_config = {
        cluster_id = 1
        cilium_version = ""
        hubble_version = ""
        role = ""
        enforcement = "default"
        prometheus = false
        hubble_url = ""
      }

      tags = {
        Environment = "lab"
        Terraform   = "true"
        Author      = "adcoutinho"
      }
    }
    lab-use2 = {
      name              = "cluster-eks-lab-use2"
      region            = "us-east-2"
      version           = "1.30"
      capacity_type     = "SPOT"
      desired_nodes     = 2
      
      # Karpenter options
      karpenter_config = {
        controller_version = "0.37.0"
      }
      # Cilium options
      cilium_config = {
        cluster_id = 1
        cilum_version = ""
        role = ""
      }

      tags = {
        Environment = "lab"
        Terraform   = "true"
        Author      = "adcoutinho"
      }
    }
  }

  name              = local.context[terraform.workspace].name
  region            = local.context[terraform.workspace].region
  version           = local.context[terraform.workspace].version
  capacity_type     = local.context[terraform.workspace].capacity_type
  desired_nodes     = local.context[terraform.workspace].desired_nodes
  karpenter_config = local.context[terraform.workspace].karpenter_config
  cilum_config = local.context[terraform.workspace].cilum_config
  tags              = local.context[terraform.workspace].tags
}
