variable "name" {
  type        = string
  description = "Name of the VPC, used as a prefix for all created resources."
}

variable "cidr" {
  type        = string
  description = "IPv4 CIDR block for the VPC."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones in which to create subnets."
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for the private subnets, one per availability zone."
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for the public subnets, one per availability zone."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to create NAT gateways for outbound internet access from private subnets."
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Whether to use a single NAT gateway for all private subnets. Not recommended for production."
}

variable "one_nat_gateway_per_az" {
  type        = bool
  default     = true
  description = "Whether to create one NAT gateway per availability zone."
}

variable "map_public_ip_on_launch" {
  type        = bool
  default     = false
  description = "Whether instances launched into public subnets receive a public IP address."
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Whether to enable DNS hostnames in the VPC."
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Whether to enable DNS resolution in the VPC."
}

variable "private_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for private subnets."
}

variable "public_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for public subnets."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources created by this module."
}
