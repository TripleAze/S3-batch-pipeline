# EBS Snapshot Automation for Jenkins Data

resource "aws_dlm_lifecycle_policy" "jenkins_backup" {
  description        = "Daily snapshots of Jenkins data volume"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily Jenkins Backup"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]  # 3 AM UTC
      }

      retain_rule {
        count = 7  # Keep 7 daily snapshots
      }

      tags_to_add = {
        SnapshotType = "DLM"
        Purpose      = "Jenkins Data Backup"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "${var.environment}-JenkinsData"
    }
  }

  tags = {
    Name        = "${var.environment}-JenkinsBackupPolicy"
    Environment = var.environment
    Project     = var.project
  }
}

# IAM role for DLM (Data Lifecycle Manager)
resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "${var.environment}-DLMLifecycleRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dlm.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.environment}-DLMRole"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "${var.environment}-DLMLifecyclePolicy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*::snapshot/*"
      }
    ]
  })
}
