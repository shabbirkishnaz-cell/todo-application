variable "name" {
  description = "Secrets Manager secret name"
  type        = string
}

variable "secret_string" {
  description = "Secret value (JSON string recommended)"
  type        = string
  sensitive   = true
}

variable "description" {
  description = "Secret description"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Days before deletion is finalized (0-30)."
  type        = number
  default     = 7
}

variable "kms_key_id" {
  description = "Optional KMS key for encryption"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
