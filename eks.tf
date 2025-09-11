module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name    = var.cluster_name
  kubernetes_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


#  enabled_cluster_log_types = [
#    "api",
#    "audit",
#    "authenticator",
#    "controllerManager",
#    "scheduler"
#  ]

  endpoint_public_access  = true
  endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      ami_type       = "AL2023_x86_64_STANDARD"
      disk_size      = 20

      update_config = {
        max_unavailable = 1
      }
    }
  }

}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# Pod identity agent (optional)
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# Node monitoring agent (optional)
resource "aws_eks_addon" "node_monitoring_agent" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "eks-node-monitoring-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
