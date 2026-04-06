variable "cluster_name" {
  description = "Used for naming and subnet tags (EKS/LBC discovery)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDRs (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Two private subnet CIDRs (one per AZ)"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "If true, create NAT gateway (single NAT) and private default route"
  type        = bool
  default     = true
}

variable "create_vpc_endpoints" {
  description = "If true, create VPC endpoints (S3 gateway + interface endpoints)"
  type        = bool
  default     = true
}

variable "endpoint_allowed_cidrs" {
  description = "CIDRs allowed to connect to interface endpoints on 443. If empty, defaults to VPC CIDR."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags"
  type        = map(string)
  default     = {}
}