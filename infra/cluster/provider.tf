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
