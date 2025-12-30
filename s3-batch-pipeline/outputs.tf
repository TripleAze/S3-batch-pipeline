output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${module.ec2.jenkins_ec2_public_ip}:8080"
}

output "jenkins_instance_id" {
  value = module.ec2.jenkins_ec2_id
}

output "pipeline_role_arn" {
  value = module.iam.pipeline_role_arn
}

output "s3_batch_role_arn" {
  value = module.iam.s3_batch_role_arn
}

output "attached_security_groups" {
  description = "Security groups attached to the Jenkins EC2"
  value       = module.ec2.attached_security_group_ids
}
