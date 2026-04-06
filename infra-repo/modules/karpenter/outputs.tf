output "controller_role_arn" {
  value = aws_iam_role.karpenter_controller.arn
}

output "interruption_queue_name" {
  value = aws_sqs_queue.karpenter_interruptions.name
}

output "node_role_name" {
  value = aws_iam_role.karpenter_node.name
}

output "node_instance_profile_name" {
  value = aws_iam_instance_profile.karpenter_node.name
}

