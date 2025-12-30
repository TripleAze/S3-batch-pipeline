variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "project" {
  type        = string
  description = "Project name for tagging"
}

variable "jenkins_ec2_role_arn" {
  type        = string
  description = "ARN of the Jenkins EC2 IAM role"
}

variable "jenkins_ec2_role_name" {
  type        = string
  description = "Name of the Jenkins EC2 IAM role"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Key pair name for EC2 access"
}

variable "security_group" {
  type        = string
  default     = null
  description = "Security group ID"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 (Ubuntu recommended)"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR block allowed to access Jenkins"
}
