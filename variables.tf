variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "my-eks-cluster"
}
variable "iam_user_arn" {
  description = "The ARN of the IAM user to access the EKS cluster"
  type        = string
  default     = "ENTER THE IAM USER ARN"
}
