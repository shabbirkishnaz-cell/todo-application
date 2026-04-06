# -------------------------
# NAT Gateway (one NAT Gateway per AZ)
# -------------------------
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 2 : 0
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-${local.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 2 : 0
  allocation_id = aws_eip.nat[count.index].id

  # NAT in the public subnet of the same AZ index
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-${local.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.this]
}

# Default route for private RT (only when NAT enabled)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 2 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-${local.azs[count.index]}"
  }
}


resource "aws_route_table_association" "private" {
  count          = var.enable_nat_gateway ? 2 : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


