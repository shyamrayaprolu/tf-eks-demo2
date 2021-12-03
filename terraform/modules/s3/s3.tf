
resource "aws_s3_bucket" "s3" {
  bucket = var.s3_bucket_name
  # force_destroy = true
  acl    = "private"
  versioning {
    enabled = true
  }
  lifecycle {
      prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_flag" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = var.publicacl_block_flag
  block_public_policy     = var.publicpolicy_block_flag
  ignore_public_acls      = var.publicacl_ignore_flag
  restrict_public_buckets = var.publicbucket_restrict_flag
}

resource "aws_s3_bucket_object" "base_folder" {
  bucket       = aws_s3_bucket.s3.id
  acl          = "private"
  key          =  var.s3_folder_structure
  content_type = "application/x-directory"
}

output "s3_id" {
  value = aws_s3_bucket.s3.id
}
