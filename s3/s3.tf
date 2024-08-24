
resource "aws_s3_bucket" "source" {
  bucket = local.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "source" {
  bucket = aws_s3_bucket.source.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "source_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.source]

  bucket = aws_s3_bucket.source.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "source" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "destination" {
  provider = aws.use2

  bucket = "${local.bucket_name}-use2"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "destination" {
  bucket = aws_s3_bucket.destination.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.use2

  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id = "${local.bucket_name}-replication"

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
