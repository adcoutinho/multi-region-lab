resource "aws_iam_role" "this" {
  for_each = var.role
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [try(each.value.managed_policy_arns)]
  tags               = var.tags
}
