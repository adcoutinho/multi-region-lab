resource "aws_iam_role" "argo" {
  for_each = local.role
  name               = each.value.name
  assume_role_policy = try(each.value.policy, data.aws_iam_policy_document.assume_role.json)
  tags               = local.tags
}
