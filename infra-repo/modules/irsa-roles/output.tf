output "lbc_role_arn" { value = aws_iam_role.lbc.arn }
output "externaldns_role_arn" { value = aws_iam_role.externaldns.arn }
/*output "karpenter_controller_role_arn" { value = aws_iam_role.karpenter_controller.arn }*/


output "external_secrets_secretsmanager_role_arn" {
  value = aws_iam_role.external_secrets_secretsmanager_irsa.arn
}


output "ecr_token_rotator_role_arn" {
  value = aws_iam_role.ecr_token_rotator_irsa.arn
}
