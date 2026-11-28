provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Stack     = "cluster"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Talks to the Kubernetes API of the cluster created in this stack.
# Authenticates with a short-lived token from `aws eks get-token` (your AWS CLI identity).
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.main.name, "--region", var.region]
  }
}
