locals {
  # IAM condition key uses the issuer host/path WITHOUT https://
  oidc_issuer_hostpath = replace(var.oidc_issuer_url, "https://", "")
}


