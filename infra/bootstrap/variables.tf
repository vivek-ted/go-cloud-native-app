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
