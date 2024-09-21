output "roles_arns" {
  description = "All Roles ARNs"
  value       = tomap({for name, role in aws_iam_role.this : name => role.arn})
}
