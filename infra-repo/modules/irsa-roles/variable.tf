variable "cluster_name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url" { type = string } # includes https://
variable "aws_account_id" { type = string }


variable "oidc_provider_url" {
  type        = string
  description = "EKS OIDC provider URL WITHOUT https:// (example: oidc.eks.us-east-1.amazonaws.com/id/XXXX)"
}

# If you want to restrict to ONE secret only, pass that secret ARN here
variable "gitlab_secret_arn" {
  type        = string
  description = "Secrets Manager secret ARN for gitlab creds (or specific secret)"
}



variable "secretsmanager_region" {
  type    = string
  default = "us-east-1"
}

variable "secretsmanager_prefix" {
  type        = string
  description = "Secrets Manager name prefix, e.g. eksdemo2/prod/"
  default     = "eksdemo2/prod/"
}


variable "ecr_token_rotator_serviceaccount" {
  type    = string
  default = "ecr-token-rotator"
}

variable "ecr_token_secret_name" {
  type    = string
  default = "eksdemo2/prod/argocd-image-updater/ecr-login-password"
}


# Pass the repo ARN(s) explicitly 
variable "ecr_repository_arns" {
  type    = list(string)
  default = ["arn:aws:ecr:us-east-1:057165950410:repository/todo-app"]
}