locals {
  common_tags = merge(
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

############################
# Subnet group (private subnets)
############################
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets-v2"
  subnet_ids = var.private_subnet_ids
  tags       = local.common_tags
}

############################
# Security group for RDS
############################
resource "aws_security_group" "db" {
  name        = "${var.name}-rds-pg-sg"
  description = "RDS PostgreSQL security group"
  vpc_id      = var.vpc_id
  tags        = local.common_tags
}

# Ingress from allowed SGs (use map keys = static, values can be unknown until apply)
resource "aws_security_group_rule" "ingress_from_allowed_sgs" {
  for_each                 = var.allowed_security_group_ids
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = each.value
  description              = "Postgres from ${each.key}"
}

# Egress all
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.db.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
}

############################
# Optional parameter group
############################
resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-pg"
  family = var.parameter_group_family
  tags   = local.common_tags

  # You can add parameters later if needed
  # parameter {
  #   name  = "log_min_duration_statement"
  #   value = "500"
  # }
}

############################
# RDS PostgreSQL instance
############################

data "aws_rds_engine_version" "postgres" {
  engine       = "postgres"
  default_only = true
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-postgres"

  engine         = "postgres"
  engine_version = data.aws_rds_engine_version.postgres.version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.db_name
  username = var.master_username

  # ✅ Let AWS generate & store the master password in Secrets Manager
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id

  port = var.port

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_retention_period > 0 ? var.preferred_backup_window : null

  maintenance_window = var.preferred_maintenance_window

  storage_encrypted = var.storage_encrypted

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final-snapshot"

  apply_immediately = var.apply_immediately

  enabled_cloudwatch_logs_exports = ["postgresql"]
  parameter_group_name            = aws_db_parameter_group.this.name

  tags = local.common_tags
}
