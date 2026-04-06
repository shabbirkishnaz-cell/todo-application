output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private[0].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}

output "nat_gateway_id" {
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
  description = "Single NAT gateway ID (null if disabled)"
}

# Endpoints outputs (null if disabled)
output "vpce_security_group_id" {
  value       = var.create_vpc_endpoints ? aws_security_group.vpce[0].id : null
  description = "Security group used by interface endpoints"
}

output "vpce_s3_id" {
  value = var.create_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "vpce_ecr_api_id" {
  value = var.create_vpc_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "vpce_ecr_dkr_id" {
  value = var.create_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "vpce_sts_id" {
  value = var.create_vpc_endpoints ? aws_vpc_endpoint.sts[0].id : null
}

output "vpce_logs_id" {
  value = var.create_vpc_endpoints ? aws_vpc_endpoint.logs[0].id : null
}