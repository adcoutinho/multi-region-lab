resource "aws_iam_role" "replication" {
  name               = "role-bucket-${local.bucket_name}-replication"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.tags
}

resource "aws_iam_policy" "replication" {
  name   = "role-bucket-${local.bucket_name}-policy-replication"
  policy = data.aws_iam_policy_document.replication.json
  tags   = local.tags
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
