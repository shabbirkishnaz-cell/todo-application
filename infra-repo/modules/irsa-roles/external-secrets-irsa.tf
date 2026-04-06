###############################################################################
# External Secrets IRSA Role (Secrets Manager)
###############################################################################

data "aws_iam_policy_document" "external_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      var.gitlab_secret_arn
    ]
  }
}


data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets-irsa"]
    }
  }
}

resource "aws_iam_role" "external_secrets_secretsmanager_irsa" {
  name               = "${var.cluster_name}-external-secrets-secretsmanager-irsa"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json
}

# New variable you should add:
# variable "secretsmanager_region" { type = string; default = "us-east-1" }
# variable "secretsmanager_prefix" { type = string } # ex: "eksdemo2/prod/"

data "aws_iam_policy_document" "external_secrets_secretsmanager_access" {

  # 1) Allow reading your app-managed secrets under eksdemo2/prod/*
  statement {
    sid    = "ReadSecretsByPrefix"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.secretsmanager_region}:${var.aws_account_id}:secret:${var.secretsmanager_prefix}*"
    ]
  }

  # 2) OPTIONAL: Allow reading AWS-managed RDS secrets (only if you really need it)
  statement {
    sid    = "ReadRDSManagedSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.secretsmanager_region}:${var.aws_account_id}:secret:rds!db-*"
      #"arn:aws:secretsmanager:us-east-1:057165950410:secret:rds!db-3865ba48-3690-4074-895a-2cf9bb14fb6e"
    ]
  }

  # 3) Optional list (ESO usually doesn’t require this, but harmless)
  statement {
    sid       = "ListSecrets"
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
}


resource "aws_iam_policy" "external_secrets_secretsmanager_access" {
  name   = "${var.cluster_name}-external-secrets-secretsmanager-access"
  policy = data.aws_iam_policy_document.external_secrets_secretsmanager_access.json
}

resource "aws_iam_role_policy_attachment" "external_secrets_attach" {
  role       = aws_iam_role.external_secrets_secretsmanager_irsa.name
  policy_arn = aws_iam_policy.external_secrets_secretsmanager_access.arn
}
