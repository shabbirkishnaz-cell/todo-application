resource "aws_sqs_queue" "karpenter_interruptions" {
  name                       = "${var.cluster_name}-karpenter-interruptions"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = true
}

# Allow EventBridge to send messages to this SQS queue
data "aws_iam_policy_document" "karpenter_interruption_queue" {
  # Keep EventBridge -> SendMessage
  statement {
    sid     = "AllowEventBridgeSendMessage"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sqs_queue.karpenter_interruptions.arn]
  }

  # ADD: Allow Karpenter controller role to read/manage messages
  statement {
    sid    = "AllowKarpenterController"
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility"
    ]

    principals {
      type = "AWS"
      #identifiers = [aws_iam_role.karpenter_controller_irsa.arn]
      # or use the role arn string if role is in another module:
      identifiers = [var.karpenter_controller_role_arn]
    }

    resources = [aws_sqs_queue.karpenter_interruptions.arn]
  }
}

resource "aws_sqs_queue_policy" "karpenter_interruptions" {
  queue_url = aws_sqs_queue.karpenter_interruptions.id
  policy    = data.aws_iam_policy_document.karpenter_interruption_queue.json
}




# EventBridge rules -> SQS target
resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name = "${var.cluster_name}-karpenter-spot-interruption"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "spot_interruption_to_sqs" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruptions.arn
}

resource "aws_cloudwatch_event_rule" "rebalance" {
  name = "${var.cluster_name}-karpenter-rebalance"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance Rebalance Recommendation"]
  })
}

resource "aws_cloudwatch_event_target" "rebalance_to_sqs" {
  rule      = aws_cloudwatch_event_rule.rebalance.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruptions.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name = "${var.cluster_name}-karpenter-instance-state-change"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "instance_state_change_to_sqs" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruptions.arn
}

resource "aws_cloudwatch_event_rule" "scheduled_change" {
  name = "${var.cluster_name}-karpenter-scheduled-change"
  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"]
  })
}

resource "aws_cloudwatch_event_target" "scheduled_change_to_sqs" {
  rule      = aws_cloudwatch_event_rule.scheduled_change.name
  target_id = "KarpenterInterruptionQueue"
  arn       = aws_sqs_queue.karpenter_interruptions.arn
}
