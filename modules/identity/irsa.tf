module "karpenter_irsa_role" {
  count = var.karpenter_enabled ? 1 : 0
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_name       = var.cluster_name
  karpenter_controller_node_iam_role_arns = var.eks_managed_node_groups_role

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = var.tags
}

module "ebs_csi_irsa_role" {
  count = var.ebs_csi_driver_enabled ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs-csi-${var.cluster_name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "external_dns_irsa_role" {
  count = var.external_dns_enabled ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                     = "external-dns-${var.cluster_name}"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = var.tags
}

module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
  count = var.load_balancer_controller_targetgroup_binding_only_enabled ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                                                       = "lb-controller-targetgroup-${var.cluster_name}"
  attach_load_balancer_controller_targetgroup_binding_only_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

module "vpc_cni_ipv4_irsa_role" {
  count = var.vpc_cni_enabled ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                      = "vpc-cni-${var.cluster_name}"
  attach_vpc_cni_policy          = true
  vpc_cni_enable_ipv4            = true
  vpc_cni_enable_cloudwatch_logs = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

################################################################################
# Custom IRSA Roles
################################################################################

module "iam_eks_role" {
  count = var.irsa_role && !var.multiregion_role ? 1 : 0
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = var.role

  role_policy_arns = {
    policy = jsonencode(var.custom_policy)
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.role_namespace}:${var.role_service_account}"]
    }
  }
}

module "iam_eks_role" {
  count = var.irsa_role && var.multiregion_role ? 1 : 0
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = var.role

  role_policy_arns = {
    policy = jsonencode(var.custom_policy)
  }

  oidc_providers = {
    one = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.role_namespace}:${var.role_service_account}"]
    }
    two = {
      provider_arn               = var.oidc_provider_arn_secondary
      namespace_service_accounts = ["${var.role_namespace}:${var.role_service_account}"]
    }
  }
}
