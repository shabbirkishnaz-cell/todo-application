variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "Base name/prefix for all resources (e.g., eksdemo2)"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags for resources"
  default     = {}
}


variable "todo_image" {
  description = "Docker image for todo app"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}


variable "private_subnet_cidrs" {
  type = list(string)

}



/*
variable "gitlab_username" {
  type        = string
  description = "GitLab username for ArgoCD Image Updater / ArgoCD HTTPS auth"
}

variable "gitlab_token" {
  type        = string
  description = "GitLab Personal Access Token (PAT) with write_repository for Image Updater; and read access for ArgoCD repo fetch"
  sensitive   = true
}*/

variable "gitlab_secret_arn" {}