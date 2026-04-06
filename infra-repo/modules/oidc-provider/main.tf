# =========================================
# 1) IRSA: Create/Associate OIDC Provider
# =========================================
# Prereq: your EKS cluster resource exists (aws_eks_cluster.this)
# EKS exposes the issuer URL at: aws_eks_cluster.this.identity[0].oidc[0].issuer

data "tls_certificate" "eks_oidc" {
  url = var.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = var.oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]

  tags = {
    Name = "${var.cluster_name}-oidc"
  }
}

