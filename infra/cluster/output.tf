output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server URL."
  value       = aws_eks_cluster.main.endpoint
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name} --alias ${aws_eks_cluster.main.name}"
}

output "vpc_id" {
  description = "VPC ID (used by the load balancer controller in B5)."
  value       = aws_vpc.main.id
}

output "node_subnet_type" {
  description = "Where the worker nodes run."
  value       = var.enable_nat_gateway ? "private (via NAT)" : "public (no NAT)"
}
