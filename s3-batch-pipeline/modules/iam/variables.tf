variable "environment" {
  type        = string
  description = "Deployment environment (prod/dev)"
}

variable "project" {
  type        = string
  description = "Project name for tagging"
}

variable "source_bucket_arn" {
  type        = string
  description = "ARN of the source S3 bucket"
}

variable "destination_bucket_arn" {
  type        = string
  description = "ARN of the destination S3 bucket"
}
