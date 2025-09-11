module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_type    = "t3.medium"
      ami_type         = "AL2_x86_64"  # Supported AMIs: AL2_x86_64, AL2_x86_64_GPU, AL2023_x86_64, BOTTLEROCKET_x86_64
      additional_security_group_ids = [aws_security_group.eks_node_sg.id]
    }
  }

  # Optional: cluster-level security group
  cluster_security_group_id = aws_security_group.eks_node_sg.id
}
