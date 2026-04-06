locals {
  oidc_issuer_hostpath = replace(var.oidc_issuer_url, "https://", "")
  discovery_value      = coalesce(var.discovery_tag, var.cluster_name)
}
