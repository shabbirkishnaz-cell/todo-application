

output "rds_postgres_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds_postgres.db_endpoint
}

output "rds_postgres_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds_postgres.db_port
}

output "rds_postgres_db_name" {
  description = "RDS DB name"
  value       = module.rds_postgres.db_name
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "rds_master_secret_arn" {
  value = module.rds_postgres.master_user_secret_arn
}


output "db_secret_name" {
  value = module.rds_postgres.db_secret_name
}
