data "http" "github_meta" {
  url = "https://api.github.com/meta"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  github_hooks_cidrs = jsondecode(data.http.github_meta.response_body).hooks
  # Filter for IPv4 only to avoid validation errors with cidr_ipv4
  github_hooks_ipv4 = [for cidr in local.github_hooks_cidrs : cidr if !can(regex(":", cidr))]
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.environment}-jenkins-sg"
  description = "Security group for Jenkins EC2"

  tags = {
    Name        = "${var.environment}-JenkinsSG"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_cidr
  description       = "SSH"
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_web" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_cidr
  description       = "Jenkins Web UI"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_cidr
  description       = "HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_cidr
  description       = "HTTPS"
}

resource "aws_vpc_security_group_ingress_rule" "icmp" {
  security_group_id = aws_security_group.jenkins_sg.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = var.allowed_cidr
  description       = "ICMP (Ping)"
}

resource "aws_vpc_security_group_ingress_rule" "github_webhooks" {
  for_each          = toset(local.github_hooks_ipv4)
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
  description       = "GitHub Webhook"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.environment}-JenkinsProfile"
  role = var.jenkins_ec2_role_name

  tags = {
    JenkinsRoleARN = var.jenkins_ec2_role_arn
  }
}

resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data_replace_on_change = true

  vpc_security_group_ids = compact([
    aws_security_group.jenkins_sg.id,
    var.security_group
  ])

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name        = "${var.environment}-JenkinsEC2"
    Environment = var.environment
    Project     = var.project
  }

user_data = <<-EOF
#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y python3 python3-pip ansible git

EOF

}



