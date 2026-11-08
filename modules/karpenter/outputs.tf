output "iam_role_arn" {
  description = "ARN of the Karpenter controller IAM role."
  value       = module.karpenter.iam_role_arn
}

output "node_iam_role_name" {
  description = "Name of the node IAM role."
  value       = module.karpenter.node_iam_role_name
}

output "queue_name" {
  description = "Name of the SQS interruption queue."
  value       = module.karpenter.queue_name
}
