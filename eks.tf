module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5" # latest available

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Custom security groups
  create_cluster_security_group = false
  create_node_security_group    = false
  cluster_security_group_id     = aws_security_group.eks_cluster_sg.id
  node_security_group_id        = aws_security_group.eks_node_sg.id

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]

      # Amazon Linux 2 AMI (latest supported)
      ami_type = "AL2_x86_64"

      # Node root volume size
      disk_size = 20
    }
  }
}

