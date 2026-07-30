variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "enable_v1_permissions" {
  type    = bool
  default = true
}

variable "enable_pod_identity" {
  type    = bool
  default = true
}

variable "create_pod_identity_association" {
  type    = bool
  default = true
}

variable "node_iam_role_additional_policies" {
  type    = map(string)
  default = {}
}

variable "namespace" {
  type    = string
  default = "karpenter"
}

variable "create_namespace" {
  type    = bool
  default = true
}

variable "name" {
  type    = string
  default = "karpenter"
}

variable "repository" {
  type    = string
  default = "oci://public.ecr.aws/karpenter"
}

variable "chart" {
  type    = string
  default = "karpenter"
}

variable "chart_version" {
  type    = string
  default = "1.0.0"
}

variable "eks_dependency" {
  type = any
}