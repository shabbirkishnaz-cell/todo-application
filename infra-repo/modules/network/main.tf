data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Project     = var.cluster_name
    },
    var.tags
  )

  # Interface endpoint SG ingress CIDRs (default to VPC CIDR if not provided)
  vpce_ingress_cidrs = length(var.endpoint_allowed_cidrs) > 0 ? var.endpoint_allowed_cidrs : [var.vpc_cidr]
}