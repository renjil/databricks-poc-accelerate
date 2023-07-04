resource "aws_s3_bucket" "metastore_bucket" {
  bucket = "${local.prefix}-${var.metastore_storage_label}"
  # acl    = "private"
  # versioning {
  #   enabled = false
  # }
  force_destroy = true
  tags = merge(local.tags, {
    Name = "${local.prefix}-${var.metastore_storage_label}"
  })
}

resource "aws_s3_bucket_ownership_controls" "metastore_bucket_ownership_control" {
  bucket = aws_s3_bucket.metastore_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "metastore_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.metastore_bucket_ownership_control]

  bucket = aws_s3_bucket.metastore_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "metastore_bucket_versioning" {
  bucket = aws_s3_bucket.metastore_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "metastore" {
  bucket                  = aws_s3_bucket.metastore_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.metastore_bucket]
}

data "aws_iam_policy_document" "passrole_for_unity_catalog" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

resource "aws_iam_policy" "unity_metastore" {
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.prefix}-databricks-unity-metastore"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          aws_s3_bucket.metastore_bucket.arn,
          "${aws_s3_bucket.metastore_bucket.arn}/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Action": [
            "sts:AssumeRole"
        ],
        "Resource": [
            "arn:aws:iam::${var.aws_account_id}:role/${local.prefix}-uc-access"
        ],
        "Effect": "Allow"
      }
    ]
  })
  tags = merge(local.tags, {
    Name = "${local.prefix}-unity-catalog IAM policy"
  })
}

// Required, in case https://docs.databricks.com/data/databricks-datasets.html are needed.
resource "aws_iam_policy" "sample_data" {
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.prefix}-databricks-sample-data"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::databricks-datasets-oregon/*",
          "arn:aws:s3:::databricks-datasets-oregon"

        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(local.tags, {
    Name = "${local.prefix}-unity-catalog-policy"
  })
}

resource "aws_iam_role" "metastore_data_access" {
  # depends_on = [
  #   aws_iam_policy.unity_metastore,
  #   aws_iam_policy.sample_data
  # ]
  name                = "${local.prefix}-uc-access"
  assume_role_policy  = data.aws_iam_policy_document.passrole_for_unity_catalog.json
  managed_policy_arns = [aws_iam_policy.unity_metastore.arn, aws_iam_policy.sample_data.arn]
  tags = merge(local.tags, {
    Name = "${local.prefix}-unity-catalog-role"
  })
}