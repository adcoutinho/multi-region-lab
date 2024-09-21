variable "role" {
  
}
variable "irsa_role" {
  
}
variable "tags" {
  
}
variable "cluster_name" {
  
}
variable "oidc_provider_arn" {
  
}
variable "oidc_provider_arn_secondary" {
  
}
variable "karpenter_enabled" {
  type = bool
}
variable "ebs_csi_driver_enabled" {
  type = bool
}
variable "external_dns_enabled" {
  type = bool
}
variable "load_balancer_controller_targetgroup_binding_only_enabled" {
  type = bool
}
variable "vpc_cni_enabled" {
  type = bool
}
variable "multiregion_role" {
  type = bool
}
variable "role_namespace" {
  
}
variable "role_service_account" {
  
}
variable "eks_managed_node_groups_role" {
  
}
variable "custom_policy" {
  
}