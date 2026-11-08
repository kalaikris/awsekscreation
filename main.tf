locals {
  region = "us-east-1"

  name = "prod-eks"

  tags = {
    Environment = "production"
    Project     = "awsekscreation"
    ManagedBy   = "terraform"
  }

  # Karpenter discovers subnets and security groups by this tag, and it must
  # match the cluster name for the controller to accept them.
  karpenter_discovery_tag = local.name
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source = "./modules/vpc"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Nodes run in public subnets, so they need a public IP for internet egress.
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "karpenter.sh/discovery" = local.karpenter_discovery_tag
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}

################################################################################
# KMS key for EKS envelope encryption of secrets
################################################################################

resource "aws_kms_key" "eks" {
  description             = "EKS secret envelope encryption for ${local.name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

################################################################################
# EKS Control Plane
################################################################################

module "eks" {
  source = "./modules/eks"

  name               = local.name
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # The public endpoint is required for the Helm and Kubectl providers to
  # reach the API server. Narrow endpoint_public_access_cidrs to your egress
  # addresses before running this in production.
  endpoint_public_access = true
  endpoint_private_access = true

  # Lets Terraform's identity administer the cluster so it can install
  # Karpenter and the add-ons. Scope this to a dedicated deploy role.
  enable_cluster_creator_admin_permissions = true

  enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config = {
    provider = {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  # Add-on IAM uses EKS Pod Identity, which does not need an OIDC provider.
  enable_irsa = false

  addons = local.addons

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.karpenter_discovery_tag
  }

  tags = local.tags
}
