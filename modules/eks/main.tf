module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  endpoint_public_access = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  enabled_log_types = var.enabled_log_types

  encryption_config = var.encryption_config
  enable_irsa = var.enable_irsa

  addons = var.addons

  node_security_group_tags = var.node_security_group_tags

  tags = var.tags
}
