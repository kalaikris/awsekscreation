variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster Karpenter provisions nodes for."
}

variable "cluster_endpoint" {
  type        = string
  description = "Endpoint of the Kubernetes API server."
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace the Karpenter controller is installed into."
}

variable "create_namespace" {
  type        = bool
  default     = false
  description = "Whether to create the Karpenter namespace."
}

variable "name" {
  type        = string
  default     = "karpenter"
  description = "Name of the Helm release."
}

variable "repository" {
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
  description = "Helm repository hosting the Karpenter chart."
}

variable "chart" {
  type        = string
  default     = "karpenter"
  description = "Name of the Karpenter Helm chart."
}

variable "chart_version" {
  type        = string
  default     = "1.0.0"
  description = "Version of the Karpenter Helm chart."
}

variable "node_iam_role_additional_policies" {
  type        = map(string)
  default     = {}
  description = "Additional IAM policies to attach to the node IAM role."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources created by this module."
}
