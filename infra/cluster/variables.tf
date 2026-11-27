variable "region" {
  description = "AWS region for the cluster."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project name used in tags."
  type        = string
  default     = "gcn"
}

variable "cluster_name" {
  description = "EKS cluster name; also prefixes related resource names."
  type        = string
  default     = "gcn"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version."
  type        = string
  default     = "1.37"
}

variable "vpc_cidr" {
  description = "IPv4 range for the whole VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "How many availability zones to spread subnets across (EKS needs at least 2)."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "enable_nat_gateway" {
  description = "true: nodes in private subnets behind one NAT gateway (production-like, ~$0.045/hr more). false: nodes in public subnets (cheapest)."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types for the node group; several types improve Spot availability."
  type        = list(string)
  default     = ["t3.medium", "t3a.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "SPOT"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Initial number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}
