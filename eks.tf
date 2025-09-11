module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cluster_security_group = false
  create_node_security_group    = false
  cluster_security_group_id     = aws_security_group.eks_cluster_sg.id
  node_security_group_id        = aws_security_group.eks_node_sg.id

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["YOUR_IP/32"]

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      ami_type       = "AL2_x86_64"
      disk_size      = 20

      update_config = {
        max_unavailable = 1
      }
    }
  }

  # IAM user access
  access_entries = [
    {
      name               = "eks-admin-access"
      principal_arn      = var.iam_user_arn
      policy_associations = [
        {
          policy_arn   = var.eks_policy_arn
          access_scope = "cluster"
        }
      ]
    }
  ]
}

# kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "coredns"
  resolve_conflicts = "OVERWRITE"
}

# VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}

# Pod identity agent (optional)
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "eks-pod-identity-agent"
  resolve_conflicts = "OVERWRITE"
}

# Node monitoring agent (optional)
resource "aws_eks_addon" "node_monitoring_agent" {
  cluster_name    = module.eks.cluster_name
  addon_name      = "eks-node-monitoring-agent"
  resolve_conflicts = "OVERWRITE"
}
