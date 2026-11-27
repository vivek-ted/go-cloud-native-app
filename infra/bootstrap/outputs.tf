output "state_bucket_name" {
  description = "S3 bucket for Terraform remote state (used in backend blocks)."
  value       = aws_s3_bucket.tf_state.bucket
}

output "ecr_repository_url" {
  description = "Push/pull URL for the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "Role ARN for aws-actions/configure-aws-credentials (GitHub variable AWS_ROLE_ARN)."
  value       = aws_iam_role.github_actions.arn
}
