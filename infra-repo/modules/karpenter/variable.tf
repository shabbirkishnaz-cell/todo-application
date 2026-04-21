variable "cluster_name" { type = string }
variable "region" { type = string }

variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url" { type = string } # includes https://

# Karpenter controller SA identity (must match what you deploy)
variable "karpenter_namespace" {
  type    = string
  default = "karpenter"
}
variable "karpenter_serviceaccount" {
  type    = string
  default = "karpenter"
}

# Used by controller iam:PassRole to attach node role to instances
variable "karpenter_node_role_name" {
  type    = string
  default = "karpenter-node-role"
}

# Discovery tag value used by Karpenter NodeClass selectors
# (you should tag subnets + SGs with karpenter.sh/discovery = <cluster_name>)
variable "discovery_tag" {
  type    = string
  default = null
}

