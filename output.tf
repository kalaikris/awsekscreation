output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "node_group_role_name" {
  value = module.eks.eks_managed_node_groups["default"].iam_role_name
}

output "eks_node_security_group_id" {
  value = aws_security_group.eks_node_sg.id
}
