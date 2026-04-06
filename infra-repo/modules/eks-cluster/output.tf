output "oidc_issuer_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "ca_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}


output "oidc_provider_url" {
  value = replace(aws_iam_openid_connect_provider.this.url, "https://", "")
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}