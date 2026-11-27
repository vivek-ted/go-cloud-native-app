terraform {
  backend "s3" {
    bucket       = "gcn-tfstate-827444110472"
    key          = "cluster/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
