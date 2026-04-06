output "eks_nodes_security_group_id" {
  description = "Security group ID attached to worker nodes"
  value       = aws_security_group.karpenter_nodes.id
}

output "karpenter_nodes_security_group_id" {
  value = aws_security_group.karpenter_nodes.id
}
