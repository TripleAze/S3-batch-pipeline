aws_region  = "eu-west-2"
project     = "S3BatchPipeline"
environment = "prod"

source_bucket      = "state-bucket-abu-source-2025"
destination_bucket = "state-bucket-abu-destination-2025"

# key_name and security_group for production access
key_name        = "production-key-pair"
security_group  = null
ami_id          = "ami-0e8d228ad90af673b"
allowed_cidr    = "102.91.72.199/32" 