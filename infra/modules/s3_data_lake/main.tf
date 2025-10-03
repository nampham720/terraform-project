resource "random_id" "suffix" {
  byte_length = 4
}
resource "aws_s3_bucket" "this" {
  bucket = "${var.name_prefix}-datalake-${random_id.suffix.hex}"
}
resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Folders (keys) to make browsing easier
resource "aws_s3_object" "prefixes" {
  for_each = toset(["raw/", "staged/", "curated/"])
  bucket   = aws_s3_bucket.this.id
  key      = each.value
  content  = ""
}
# Enforce HTTPS-only
resource "aws_s3_bucket_policy" "tls" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "DenyInsecureTransport",
      Effect    = "Deny",
      Principal = "*",
      Action    = "s3:*",
      Resource  = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ],
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}
