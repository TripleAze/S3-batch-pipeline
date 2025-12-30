output "pipeline_role_arn_out" {
  value = var.pipeline_role_arn
}

output "s3_batch_role_arn_out" {
  value = var.s3_batch_role_arn
}

output "source_bucket_out" {
  value = var.source_bucket
}

output "destination_bucket_out" {
  value = var.destination_bucket
}

output "manifest_s3_key_out" {
  value = var.manifest_s3_key
}

output "aws_region_out" {
  value = var.aws_region
}
