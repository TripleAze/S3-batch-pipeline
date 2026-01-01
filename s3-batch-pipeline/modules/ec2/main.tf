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

# Get default subnet to determine availability zone for EBS volume
data "aws_subnet" "selected" {
  default_for_az = true
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_availability_zones" "available" {
  state = "available"
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
  description       = "Jenkins Web UI (Admin Access)"
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

# Explicit egress rules for production security
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "HTTPS to internet (package updates, AWS APIs)"
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "HTTP to internet (package updates)"
}

resource "aws_vpc_security_group_egress_rule" "dns_udp" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "DNS (UDP)"
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "DNS (TCP)"
}

resource "aws_vpc_security_group_egress_rule" "ntp" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 123
  to_port           = 123
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "NTP (time synchronization)"
}

# Dedicated EBS volume for Jenkins data persistence
resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.jenkins_data_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name        = "${var.environment}-JenkinsData"
    Environment = var.environment
    Project     = var.project
    Purpose     = "Jenkins persistent data (/var/lib/jenkins)"
  }

  lifecycle {
    prevent_destroy = false  # Set to true in production to prevent accidental deletion
  }
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
  availability_zone           = aws_ebs_volume.jenkins_data.availability_zone

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

# Wait for EBS volume attachment
sleep 10

# Format and mount Jenkins data volume if not already formatted
if ! blkid /dev/xvdf; then
  mkfs.ext4 /dev/xvdf
fi

# Create mount point
mkdir -p /var/lib/jenkins

# Mount the volume
mount /dev/xvdf /var/lib/jenkins

# Add to fstab for persistence across reboots
echo "/dev/xvdf /var/lib/jenkins ext4 defaults,nofail 0 2" >> /etc/fstab

# Set ownership (Jenkins user will be created by Ansible)
chown -R 1000:1000 /var/lib/jenkins || true

EOF

}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "jenkins_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.jenkins_data.id
  instance_id = aws_instance.jenkins.id

  # Ensure volume is detached before instance replacement
  stop_instance_before_detaching = true
}


##