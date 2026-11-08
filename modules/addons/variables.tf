variable "name" {
  type        = string
  description = "Name of the EKS cluster the add-ons are installed into."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources created by this module."
}
