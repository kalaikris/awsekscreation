output "vpc_cni_role_arn" {
  description = "ARN of the IAM role associated with the VPC CNI service account."
  value       = aws_iam_role.vpc_cni.arn
}

output "ebs_csi_role_arn" {
  description = "ARN of the IAM role associated with the EBS CSI driver service account."
  value       = aws_iam_role.ebs_csi.arn
}

output "addons" {
  description = "Map of EKS managed add-on configurations."
  value       = local.addons
}
