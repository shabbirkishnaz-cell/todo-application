output "db_instance_id" {
  value       = aws_db_instance.this.id
  description = "RDS instance ID"
}

output "db_endpoint" {
  value       = aws_db_instance.this.address
  description = "RDS endpoint hostname"
}

output "db_port" {
  value       = aws_db_instance.this.port
  description = "RDS port"
}

output "db_name" {
  value       = aws_db_instance.this.db_name
  description = "Database name"
}

output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "DB security group ID"
}


# ✅ This is the Secrets Manager secret AWS created for the master user
output "master_user_secret_arn" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "db_secret_name" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}