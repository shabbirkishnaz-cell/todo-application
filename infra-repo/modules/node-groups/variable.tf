# Variables you likely want
variable "nodegroup_name" {
  type    = string
  default = "ng-public1"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_desired_size" {
  type    = number
  default = 4
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "node_disk_size" {
  type    = number
  default = 20
}

variable "ssh_key_name" {
  type        = string
  description = "Existing EC2 key pair name (like eksctl --ssh-public-key)"
  default     = "kube-demo"
}


variable "cluster_name" {
  type    = string
  default = "eksdemo2"
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ssh_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH to nodes (e.g., [\"203.0.113.10/32\"])"
}

