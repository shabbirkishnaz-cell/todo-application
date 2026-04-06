# -------------------------
# VPC Endpoints (reduce NAT cost + keep AWS traffic private)
# -------------------------

# Security Group for Interface Endpoints
resource "aws_security_group" "vpce" {
  count       = var.create_vpc_endpoints ? 1 : 0
  name        = "${var.cluster_name}-vpce-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-vpce-sg"
  })
}

resource "aws_security_group_rule" "vpce_ingress_443" {
  count             = var.create_vpc_endpoints ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.vpce[0].id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.vpce_ingress_cidrs
  description       = "Allow HTTPS from allowed CIDRs to Interface Endpoints"
}

resource "aws_security_group_rule" "vpce_egress_all" {
  count             = var.create_vpc_endpoints ? 1 : 0
  type              = "egress"
  security_group_id = aws_security_group.vpce[0].id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress"
}

# --- S3 Gateway Endpoint (requires route table IDs) ---
resource "aws_vpc_endpoint" "s3" {
  count             = var.create_vpc_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpce-s3" })
}

# --- Interface endpoints (private DNS enabled) ---
resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.create_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpce-ecr-api" })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.create_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpce-ecr-dkr" })
}

resource "aws_vpc_endpoint" "sts" {
  count               = var.create_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpce-sts" })
}

resource "aws_vpc_endpoint" "logs" {
  count               = var.create_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpce[0].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, { Name = "${var.cluster_name}-vpce-logs" })
}