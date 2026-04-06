data "aws_iam_policy_document" "irsa_trust" {
  for_each = {
    lbc         = { ns = "kube-system", sa = "aws-load-balancer-controller" }
    externaldns = { ns = "external-dns", sa = "external-dns" }
    karpenter   = { ns = "karpenter", sa = "karpenter" }
  }

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
      values   = ["system:serviceaccount:${each.value.ns}:${each.value.sa}"]
    }
  }
}


/********/

resource "aws_iam_policy" "lbc" {
  name   = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/policies/lbc_iam_policy.json")

}

resource "aws_iam_role" "lbc" {
  name               = "${var.cluster_name}-lbc-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust["lbc"].json
}

resource "aws_iam_role_policy_attachment" "lbc_attach" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}



/*******/

data "aws_iam_policy_document" "externaldns" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "externaldns" {
  name   = "${var.cluster_name}-ExternalDNSPolicy"
  policy = data.aws_iam_policy_document.externaldns.json
}

resource "aws_iam_role" "externaldns" {
  name               = "${var.cluster_name}-externaldns-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust["externaldns"].json
}

resource "aws_iam_role_policy_attachment" "externaldns_attach" {
  role       = aws_iam_role.externaldns.name
  policy_arn = aws_iam_policy.externaldns.arn
}

/*******/
data "aws_iam_policy_document" "karpenter_controller" {
  # Read-only describes
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcs",
      "ssm:GetParameter",
      "pricing:GetProducts"
    ]
    resources = ["*"]
  }

  # Provision / manage capacity
  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]
    resources = ["*"]
  }

  # Needed so Karpenter can attach instance profile / role to nodes it creates
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${var.aws_account_id}:role/${var.cluster_name}-karpenter-node-role"
    ]
  }

  # EKS cluster info
  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = ["*"]
  }

  # Optional (some setups): instance profile management; required in some Karpenter versions/features
  statement {
    effect = "Allow"
    actions = [
      "iam:GetInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:ListInstanceProfiles"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "${var.cluster_name}-KarpenterControllerPolicy"
  policy = data.aws_iam_policy_document.karpenter_controller.json
}

/*resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust["karpenter"].json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}*/


