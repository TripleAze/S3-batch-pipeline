variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "S3BatchPipeline"
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "dev"
}

variable "key_name" {
  description = "SSH Key Pair name"
  type        = string
  default     = null
}

variable "security_group" {
  description = "Security Group ID (optional, managed by module if omitted)"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID for EC2 Instance"
  type        = string
}

variable "source_bucket" {
  type = string
}

variable "destination_bucket" {
  type = string
}

variable "manifest_s3_key" {
  description = "S3 key for the manifest CSV"
  type        = string
  default     = "manifest.csv"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access Jenkins"
  type        = string
  default     = "197.210.76.212/32"
}
