variable "region" {
  description = "AWS region for all bootstrap resources."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project name used in resource names and tags."
  type        = string
  default     = "gcn"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI role, as owner/name."
  type        = string
  default     = "vivek-ted/go-cloud-native-app"
}

variable "github_branch" {
  description = "Only workflows running on this branch may push images."
  type        = string
  default     = "main"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository holding the application image."
  type        = string
  default     = "go-cloud-native-app"
}

variable "images_to_keep" {
  description = "How many most recent images ECR keeps before expiring older ones."
  type        = number
  default     = 10
}

variable "github_oidc_sub_prefix" {
  description = "Subject prefix GitHub puts in this repo's OIDC tokens. Find it with: gh api repos/OWNER/REPO/actions/oidc/customization/sub --jq .sub_claim_prefix"
  type        = string
  default     = "repo:vivek-ted@13916323/go-cloud-native-app@1470095668"
}

variable "eks_cluster_name" {
  description = "EKS cluster the CI role may look up (to build a kubeconfig)."
  type        = string
  default     = "gcn"
}