#module "karpenter_irsa_role" {
#  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  role_name                          = "karpenter_controller_${terraform.workspace}"
#  attach_karpenter_controller_policy = true
#
#  karpenter_controller_cluster_name         = module.eks.cluster_name
#  karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["initial"].iam_role_arn]
#
#  attach_vpc_cni_policy = true
#  vpc_cni_enable_ipv4   = true
#
#  oidc_providers = {
#    main = {
#      provider_arn               = module.eks.oidc_provider_arn
#      namespace_service_accounts = ["default:my-app", "canary:my-app"]
#    }
#  }
#}
