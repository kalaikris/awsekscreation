################################################################################
# EKS Managed Add-ons
#
# The VPC CNI, EBS CSI driver, CoreDNS, kube-proxy, metrics-server and
# kube-state-metrics are all installed through the EKS add-ons API, so AWS
# owns their lifecycle and upgrades.
#
# VPC CNI and the EBS CSI driver need IAM permissions. Both are granted
# through EKS Pod Identity, which the eks-pod-identity-agent add-on provides,
# so no OIDC provider or IRSA role is required.
################################################################################

################################################################################
# IAM roles for the add-ons
################################################################################

data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  name               = "${var.name}-vpc-cni"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = var.tags
}

# Cluster-scoped policy restricts the driver to volumes in this cluster only.
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEBSCSIDriverEKSClusterScopedPolicy"
}

################################################################################
# Add-on configuration
################################################################################

locals {
  addons = {
    # Must be installed before any node group, otherwise nodes cannot join.
    eks-pod-identity-agent = {
      before_compute = true
    }

    vpc-cni = {
      before_compute = true

      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })

      pod_identity_association = [{
        role_arn        = aws_iam_role.vpc_cni.arn
        service_account = "aws-node"
      }]
    }

    coredns = {
      configuration_values = jsonencode({
        replicaCount = 3
        resources = {
          limits = {
            cpu    = "100m"
            memory = "170Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "70Mi"
          }
        }
      })
    }

    kube-proxy = {}

    aws-ebs-csi-driver = {
      configuration_values = jsonencode({
        controller = {
          serviceAccount = {
            annotations = {
              "eks.amazonaws.com/ebs-csi-driver" = "true"
            }
          }
        }
      })

      pod_identity_association = [{
        role_arn        = aws_iam_role.ebs_csi.arn
        service_account = "ebs-csi-controller-sa"
      }]
    }

    metrics-server = {
      configuration_values = jsonencode({
        args = [
          "--kubelet-insecure-tls",
          "--node-metrics-grace-period=60s",
        ]
      })
    }

    # Community add-on. AWS validates version compatibility but does not
    # support the component itself.
    kube-state-metrics = {}
  }
}
