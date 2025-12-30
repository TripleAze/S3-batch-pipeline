output "jenkins_ec2_role_arn" {
  value = aws_iam_role.jenkins_ec2_role.arn
}

output "jenkins_ec2_role_name" {
  value = aws_iam_role.jenkins_ec2_role.name
}

output "pipeline_role_arn" {
  value = aws_iam_role.pipeline_role.arn
}

output "s3_batch_role_arn" {
  value = aws_iam_role.s3_batch_role.arn
}
