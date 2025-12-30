# Source Bucket
resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
# Versioning
resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "source_encryption" {
  bucket = aws_s3_bucket.source.id

  dynamic "rule" {
    for_each = var.enable_encryption ? [1] : []
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Destination Bucket
resource "aws_s3_bucket" "destination" {
  bucket = var.destination_bucket

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "destination_versioning" {
  bucket = aws_s3_bucket.destination.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "destination_encryption" {
  bucket = aws_s3_bucket.destination.id

  dynamic "rule" {
    for_each = var.enable_encryption ? [1] : []
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
