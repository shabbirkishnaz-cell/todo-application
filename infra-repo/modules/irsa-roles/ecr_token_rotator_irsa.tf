#############################################
# ECR Token Rotator IRSA (writes to Secrets Manager)
#############################################

locals {
  region        = try(var.secretsmanager_region, "us-east-1")
  oidc_hostpath = replace(var.oidc_issuer_url, "https://", "")
}

# --- TRUST POLICY (IRSA) ---
data "aws_iam_policy_document" "ecr_token_rotator_irsa_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostpath}:sub"
      values   = ["system:serviceaccount:argocd:${var.ecr_token_rotator_serviceaccount}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecr_token_rotator_irsa" {
  name               = "eksdemo2-ecr-token-rotator-irsa"
  assume_role_policy = data.aws_iam_policy_document.ecr_token_rotator_irsa_trust.json
}

# --- PERMISSIONS POLICY ---
data "aws_iam_policy_document" "ecr_token_rotator_policy" {

  # Needed to generate the Docker auth token (get-login-password)
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # IMPORTANT: allow token's principal to read from your repo
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = var.ecr_repository_arns
  }

  # Secrets Manager updates (scoped to your secret prefix)
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:PutSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${local.region}:${var.aws_account_id}:secret:${var.ecr_token_secret_name}*"
    ]
  }

  # CreateSecret can't be scoped tightly pre-create
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:CreateSecret"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_token_rotator_policy" {
  name   = "eksdemo2-ecr-token-rotator-policy"
  policy = data.aws_iam_policy_document.ecr_token_rotator_policy.json
}

resource "aws_iam_role_policy_attachment" "ecr_token_rotator_attach" {
  role       = aws_iam_role.ecr_token_rotator_irsa.name
  policy_arn = aws_iam_policy.ecr_token_rotator_policy.arn
}
