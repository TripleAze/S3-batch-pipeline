# Root module - Production S3 Batch Pipeline

# Load S3 module (Must be loaded to provide ARNs)
module "s3" {
  source = "./modules/s3"

  environment = var.environment
  project     = var.project

  source_bucket      = var.source_bucket
  destination_bucket = var.destination_bucket
}

# Load IAM module
module "iam" {
  source = "./modules/iam"

  environment = var.environment
  project     = var.project

  # Use ARNs from S3 module to scope policies strictly
  source_bucket_arn      = module.s3.source_bucket_arn
  destination_bucket_arn = module.s3.destination_bucket_arn
}

# Load EC2 module
module "ec2" {
  source = "./modules/ec2"

  environment = var.environment
  project     = var.project

  # Pass the Jenkins EC2 IAM role created in IAM module
  jenkins_ec2_role_arn  = module.iam.jenkins_ec2_role_arn
  jenkins_ec2_role_name = module.iam.jenkins_ec2_role_name

  # Key pair and security group variables
  key_name       = var.key_name
  security_group = var.security_group
  ami_id         = var.ami_id
  allowed_cidr   = var.allowed_cidr
}

# Load Pipeline module
module "pipeline" {
  source = "./modules/pipeline"

  environment = var.environment
  project     = var.project

  pipeline_role_arn  = module.iam.pipeline_role_arn
  s3_batch_role_arn  = module.iam.s3_batch_role_arn
  source_bucket      = module.s3.source_bucket
  destination_bucket = module.s3.destination_bucket
  manifest_s3_key    = var.manifest_s3_key
  aws_region         = var.aws_region
}
