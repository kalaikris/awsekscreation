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

  eks_addons = {
    kube_proxy = {
      addon_name       = "kube-proxy"
      addon_version    = "v1.32.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
    coredns = {
      addon_name       = "coredns"
      addon_version    = "v1.12.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
    vpc_cni = {
      addon_name       = "vpc-cni"
      addon_version    = "v1.14.0-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
  }

  # New IAM access entries
  access_entries = [
    {
      name               = "eks-admin-access"
      principal_arn      = var.iam_user_arn      # IAM User ARN
      policy_associations = [
        {
          policy_arn   = var.eks_policy_arn      # Example: EKSAdminPolicy ARN
          access_scope = "cluster"               # scope can be "cluster" or "namespace"
        }
      ]
    }
  ]
}
