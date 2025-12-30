output "jenkins_ec2_id" {
  value = aws_instance.jenkins.id
}

output "jenkins_ec2_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_ec2_private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "jenkins_sg_id" {
  value = aws_security_group.jenkins_sg.id
}

output "attached_security_group_ids" {
  value = aws_instance.jenkins.vpc_security_group_ids
}
