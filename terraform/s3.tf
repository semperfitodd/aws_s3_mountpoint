locals {
  mime_types = {
    txt = "text/plain"
  }
}

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  acl                     = "private"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  force_destroy = true

  expected_bucket_owner = data.aws_caller_identity.this.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_object" "website-object" {
  bucket       = module.s3.s3_bucket_id
  for_each     = fileset("./files/", "**/*")
  key          = each.value
  source       = "./files/${each.value}"
  etag         = filemd5("./files/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}
