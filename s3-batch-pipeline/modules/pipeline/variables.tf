variable "environment" {
  type        = string
  description = "Deployment environment (prod/dev)"
}

variable "project" {
  type        = string
  description = "Project name for tagging"
}

variable "pipeline_role_arn" {
  type        = string
  description = "ARN of the pipeline IAM role to be assumed by Jenkins"
}

variable "s3_batch_role_arn" {
  type        = string
  description = "ARN of the S3 Batch Operations role"
}

variable "source_bucket" {
  type        = string
  description = "Name of the source S3 bucket"
}

variable "destination_bucket" {
  type        = string
  description = "Name of the destination S3 bucket"
}

variable "manifest_s3_key" {
  type        = string
  description = "S3 key for the manifest CSV"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}
