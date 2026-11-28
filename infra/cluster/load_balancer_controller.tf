# AWS Load Balancer Controller: watches Ingress objects and creates ALBs for them.
# It runs as pods in kube-system and gets AWS permissions through EKS Pod Identity.

locals {
  lbc_namespace       = "kube-system"
  lbc_service_account = "aws-load-balancer-controller"
}

data "aws_iam_policy_document" "pod_identity_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lbc" {
  name               = "${var.cluster_name}-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_assume.json
}

resource "aws_iam_policy" "lbc" {
  name        = "${var.cluster_name}-aws-load-balancer-controller"
  description = "Permissions for the AWS Load Balancer Controller (chart ${var.lbc_chart_version})."
  policy      = file("${path.module}/policies/aws-load-balancer-controller-v${var.lbc_chart_version}.json")
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = local.lbc_namespace
  service_account = local.lbc_service_account
  role_arn        = aws_iam_role.lbc.arn
}

resource "helm_release" "lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.lbc_chart_version
  namespace  = local.lbc_namespace

  values = [yamlencode({
    clusterName = aws_eks_cluster.main.name
    region      = var.region
    vpcId       = aws_vpc.main.id
    serviceAccount = {
      create = true
      name   = local.lbc_service_account
    }
  })]

  depends_on = [
    aws_eks_node_group.default,
    aws_eks_addon.before_nodes,
    aws_eks_pod_identity_association.lbc,
    aws_iam_role_policy_attachment.lbc,
  ]
}