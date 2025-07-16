resource "aws_s3_bucket" "static_assets" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags = {
    Name        = "StaticAssets"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  index_document { suffix = "index.html" }
}

resource "aws_s3_bucket_public_access_block" "static_assets_block" {
  bucket                  = aws_s3_bucket.static_assets.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_assets.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.static_assets.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.static_assets_block]
}
