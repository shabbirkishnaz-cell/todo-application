# =========================================
# 2) Managed Node Group in PRIVATE subnets
#    (like your eksctl create nodegroup)
# =========================================



# For remote access, EKS requires a source SG that is allowed to SSH to nodes
resource "aws_security_group" "node_ssh" {
  name        = "${var.cluster_name}-node-ssh"
  description = "SSH access to EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from your IP (replace with your corporate/public IP CIDR)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "karpenter_nodes" {
  name        = "${var.cluster_name}-karpenter-nodes"
  description = "Security group for nodes launched by Karpenter"
  vpc_id      = var.vpc_id

  # minimal egress; refine later
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                     = "${var.cluster_name}-karpenter-nodes"
    "karpenter.sh/discovery" = var.cluster_name
  }
}


# IAM role for worker nodes
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Core worker node policies (minimum for managed node groups)
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ECR_ReadOnly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Extra policies to match your eksctl flags (attach only if you truly need them)
# --asg-access
resource "aws_iam_role_policy_attachment" "node_AutoScalingFullAccess" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# --external-dns-access (Route53 access for ExternalDNS)
resource "aws_iam_role_policy_attachment" "node_Route53FullAccess" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

# --full-ecr-access
resource "aws_iam_role_policy_attachment" "node_ECR_FullAccess" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# --appmesh-access
resource "aws_iam_role_policy_attachment" "node_AppMeshFullAccess" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
}

# NOTE on --alb-ingress-access:
# The AWS Load Balancer Controller is best done via IRSA (service account role),
# NOT via node role. If you still want node role access, you'd attach a policy here,
# but production best practice: create an IRSA role for the controller pod.

resource "aws_eks_node_group" "private" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${var.nodegroup_name}"
  node_role_arn   = aws_iam_role.node.arn

  subnet_ids = var.subnet_ids

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

/*
  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.node_ssh.id]
  }
*/

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_ECR_ReadOnly
  ]

  tags = {
    Name = "${var.cluster_name}-${var.nodegroup_name}"
  }
}
