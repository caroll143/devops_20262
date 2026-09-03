output "iam_users" {
  description = "Usuários IAM criados"
  value = [
    aws_iam_user.juliana_dev.name,
    aws_iam_user.rafael_platform.name,
    aws_iam_user.lucas_intern.name
  ]
}

output "iam_groups" {
  description = "Grupos IAM criados"
  value = [
    aws_iam_group.developers.name,
    aws_iam_group.platform_eng.name
  ]
}

output "policy_arns" {
  description = "ARNs das policies customizadas"
  value = {
    s3_read          = aws_iam_policy.s3_read.arn
    ec2_s3_full      = aws_iam_policy.ec2_s3_full.arn
    deny_destructive = aws_iam_policy.deny_destructive.arn
  }
}

output "ec2_role_arn" {
  description = "ARN da role utilizada pelo EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile" {
  description = "Nome do Instance Profile do EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}