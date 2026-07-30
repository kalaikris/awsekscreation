output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "karpenter_iam_role_arn" {
  value = module.karpenter.iam_role_arn
}