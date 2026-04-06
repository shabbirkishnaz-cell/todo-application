variable "cluster_name" {
  type = string
}


variable "region" {
  type = string
}


variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "subnet_ids" {}

variable "vpc_cidr_block" {
  type = string
}