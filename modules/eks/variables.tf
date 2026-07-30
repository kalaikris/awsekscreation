variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "eks_managed_node_groups" {
  type = any
}