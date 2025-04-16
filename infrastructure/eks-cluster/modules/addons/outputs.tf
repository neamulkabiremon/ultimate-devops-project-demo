output "autoscaler_role_arn" {
  value = aws_iam_role.autoscaler.arn
}

output "lbc_role_arn" {
  value = aws_iam_role.lbc.arn
}
