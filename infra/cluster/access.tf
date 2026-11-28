# The platform (this stack) owns the namespace; the CI pipeline only deploys into it.
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
    }
  }

  depends_on = [aws_eks_node_group.default, helm_release.lbc]
}

data "aws_iam_role" "github_actions" {
  name = var.github_actions_role_name
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = data.aws_iam_role.github_actions.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_edit" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.github_actions.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = [kubernetes_namespace_v1.app.metadata[0].name]
  }
}