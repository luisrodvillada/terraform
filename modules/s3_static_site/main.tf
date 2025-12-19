//Create the Bucket

resource "aws_s3_bucket" "static_site" {
  bucket = var.static_bucket_name

  tags = {
    Name = "static-site-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_object" "static_files" {
  for_each = fileset(var.local_static_path, "**")

  bucket = aws_s3_bucket.static_site.bucket
  key    = each.value
  source = "${var.local_static_path}/${each.value}"

  etag = filemd5("${var.local_static_path}/${each.value}")
}
