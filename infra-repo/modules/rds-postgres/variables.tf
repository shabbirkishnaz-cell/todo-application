variable "name" {
  type        = string
  description = "Base name/prefix (e.g., eksdemo2-db)"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "tags" {
  type        = map(string)
  description = "Extra tags"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for DB subnet group"
}

# Map keys must be static; values can be computed
variable "allowed_security_group_ids" {
  type        = map(string)
  description = "Map of SGs allowed to access DB (e.g., {eks_nodes=..., app=...})"
  default     = {}
}

variable "db_name" {
  type        = string
  description = "Initial database name"
  default     = "todo"
}

variable "master_username" {
  type        = string
  description = "DB master username"
  default     = "postgres"
}

variable "master_user_secret_kms_key_id" {
  type        = string
  default     = null
  description = "Optional KMS key ID/ARN to encrypt the RDS managed master user secret in Secrets Manager"
}


variable "port" {
  type        = number
  description = "DB port"
  default     = 5432
}

# Free-tier friendly defaults
variable "instance_class" {
  type        = string
  description = "DB instance class"
  default     = "db.t3.micro"
}

variable "engine_version" {
  type        = string
  description = "Postgres engine version"
  default     = "15.4"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage (GiB)"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Max autoscaling storage (GiB)"
  default     = 50
}

variable "multi_az" {
  type        = bool
  description = "Multi-AZ deployment"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention days (0 disables backups)"
  default     = 1
}

variable "preferred_backup_window" {
  type        = string
  description = "Backup window if retention > 0"
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  type        = string
  description = "Maintenance window"
  default     = "sun:05:00-sun:06:00"
}

variable "storage_encrypted" {
  type        = bool
  description = "Enable storage encryption"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Prevent accidental deletion"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on delete"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
  default     = true
}

variable "parameter_group_family" {
  type        = string
  description = "Parameter group family"
  default     = "postgres17"
}
