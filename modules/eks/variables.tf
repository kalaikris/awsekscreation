variable "name" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the control plane."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which to create the cluster."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs used by the control plane and the managed node groups."
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Whether the Kubernetes API server endpoint is reachable from outside the VPC."
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Whether the Kubernetes API server endpoint is reachable from within the VPC."
}

variable "enable_cluster_creator_admin_permissions" {
  type        = bool
  default     = false
  description = "Whether the identity that creates the cluster is granted cluster-admin access."
}

variable "enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Control plane log types to enable."
}

variable "encryption_config" {
  type        = any
  default     = null
  description = "KMS key configuration used for envelope encryption of Kubernetes secrets."
}

variable "enable_irsa" {
  type        = bool
  default     = false
  description = "Whether to create an OIDC provider for IAM roles for service accounts. EKS Pod Identity does not require it."
}

variable "addons" {
  type        = any
  default     = {}
  description = "Map of EKS managed add-on configurations."
}

variable "node_security_group_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for the node security group. Karpenter discovers it by the karpenter.sh/discovery tag."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources created by this module."
}
