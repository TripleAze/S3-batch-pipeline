# 1. Jenkins EC2 Role

resource "aws_iam_role" "jenkins_ec2_role" {
  name = "${var.environment}-JenkinsEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_policy" "jenkins_ec2_policy" {
  name = "${var.environment}-JenkinsEC2Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sts:AssumeRole"]
      Resource = "*" # Can later limit to pipeline role ARN
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  role       = aws_iam_role.jenkins_ec2_role.name
  policy_arn = aws_iam_policy.jenkins_ec2_policy.arn
}

##########################
# 2. Pipeline Role
##########################
resource "aws_iam_role" "pipeline_role" {
  name = "${var.environment}-PipelineRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = [
        aws_iam_role.jenkins_ec2_role.arn,
        "arn:aws:iam::272117124614:user/liman"
      ] }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_policy" "pipeline_policy" {
  name = "${var.environment}-PipelinePolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.source_bucket_arn,
          "${var.source_bucket_arn}/*",
          var.destination_bucket_arn,
          "${var.destination_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = "*" # Can later limit to S3 Batch role ARN
      },
      {
        Effect = "Allow"
        Action = [
          "s3:CreateJob",
          "s3:DescribeJob",
          "s3:ListJobs",
          "s3:UpdateJobStatus",
          "s3:UpdateJobPriority",
          "s3:UpdateJobStatus"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pipeline_attach" {
  role       = aws_iam_role.pipeline_role.name
  policy_arn = aws_iam_policy.pipeline_policy.arn
}

##########################
# 3. S3 Batch Operations Role
##########################
resource "aws_iam_role" "s3_batch_role" {
  name = "${var.environment}-S3BatchOperationsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "batchoperations.s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_policy" "s3_batch_policy" {
  name = "${var.environment}-S3BatchPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.source_bucket_arn,
          "${var.source_bucket_arn}/*",
          var.destination_bucket_arn,
          "${var.destination_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_batch_attach" {
  role       = aws_iam_role.s3_batch_role.name
  policy_arn = aws_iam_policy.s3_batch_policy.arn
}
