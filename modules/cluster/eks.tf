locals {
  partition          = data.aws_partition.current.partition
  account_id         = data.aws_caller_identity.current.account_id
  service_cidr       = "10.176.0.0/20"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = var.eks_module_version

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  cluster_service_ipv4_cidr      = local.service_cidr

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    aws-ebs-csi-driver     = {}

  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    initial = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]
      capacity_type  = var.instance_capacity_type

      min_size     = 1
      max_size     = 10
      desired_size = var.desired_nodes

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }

      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  node_security_group_tags = merge(var.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  #access_entries = {
  #  # One access entry with a policy associated
  #  example = {
  #    kubernetes_groups = []
  #    principal_arn     = "arn:aws:iam::${local.account_id}:role/argo"
#
  #    policy_associations = {
  #      example = {
  #        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #        access_scope = {
  #          namespaces = ["default"]
  #          type       = "namespace"
  #        }
  #      }
  #    }
  #  }
  #}

  tags = merge(var.tags, { Name = var.cluster_name })
}
