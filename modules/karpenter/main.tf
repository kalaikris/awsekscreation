################################################################################
# Karpenter IAM, interruption queue and node role
#
# The eks module's karpenter submodule creates the controller IAM role, the
# Pod Identity association, the node IAM role with its access entry, and the
# SQS interruption queue.
################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = var.cluster_name

  # The controller reaches the API server through the node role's access
  # entry, so the node role needs the CNI policy to join the cluster.
  create_access_entry = true
  access_entry_type  = "EC2_LINUX"

  create_pod_identity_association = true
  namespace                       = var.namespace
  service_account                 = var.name

  node_iam_role_additional_policies = var.node_iam_role_additional_policies

  tags = var.tags
}

################################################################################
# Karpenter controller
################################################################################

data "aws_ecrpublic_authorization_token" "token" {}

resource "helm_release" "karpenter" {
  namespace        = var.namespace
  create_namespace = var.create_namespace

  name                = var.name
  repository          = var.repository
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = var.chart
  version             = var.chart_version

  wait = true

  values = [
    <<-EOT
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
      eksControlPlane: true
    EOT
  ]

  depends_on = [module.karpenter]
}

################################################################################
# EC2NodeClass
#
# Nodes land in the public subnets and get a public IP so they can reach the
# AWS APIs and the internet without a NAT gateway.
################################################################################

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2023
      amiSelectorTerms:
        - alias: al2023@latest
      role: ${module.karpenter.node_iam_role_name}
      associatePublicIPAddress: true
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
  YAML

  depends_on = [helm_release.karpenter]
}

################################################################################
# NodePool
################################################################################

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            group: karpenter.k8s.aws
            kind: EC2NodeClass
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["t", "m"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["2", "4", "8"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "topology.kubernetes.io/zone"
              operator: In
              values: ["us-east-1a", "us-east-1b"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [kubectl_manifest.karpenter_node_class]
}
