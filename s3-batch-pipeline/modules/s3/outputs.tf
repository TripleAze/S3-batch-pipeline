output "source_bucket" {
  value = aws_s3_bucket.source.bucket
}

output "destination_bucket" {
  value = aws_s3_bucket.destination.bucket
}

output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}

output "destination_bucket_arn" {
  value = aws_s3_bucket.destination.arn
}
