############################
# ArgoCD Image Updater IRSA
############################

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "image_updater_serviceaccount" {
  type    = string
  default = "argocd-image-updater"
}

data "aws_iam_policy_document" "argocd_image_updater_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:${var.argocd_namespace}:${var.image_updater_serviceaccount}"]
    }
  }
}

resource "aws_iam_role" "argocd_image_updater" {
  name               = "${var.cluster_name}-argocd-image-updater-irsa"
  assume_role_policy = data.aws_iam_policy_document.argocd_image_updater_irsa_trust.json
}

data "aws_iam_policy_document" "argocd_image_updater" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "argocd_image_updater" {
  name   = "${var.cluster_name}-ArgoCDImageUpdaterECRReadOnly"
  policy = data.aws_iam_policy_document.argocd_image_updater.json
}

resource "aws_iam_role_policy_attachment" "argocd_image_updater" {
  role       = aws_iam_role.argocd_image_updater.name
  policy_arn = aws_iam_policy.argocd_image_updater.arn
}
