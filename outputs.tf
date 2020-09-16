output "gitlab-provision-role-arn" {
  value       = aws_iam_role.gitlab.arn
  description = "The Amazon Resource Name (ARN) associated with the GitLab provisioning role."
}