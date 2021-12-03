### Deploy helm here
# Helm Provider - use helm provider w/ EKS credentials


provider "helm" {
  # The 1.0 will enable helm3
  version                  = "~> 1.0"
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_certificate_authority_data
    token                  = var.cluster_auth_token
    load_config_file       = false
  }
}

data "aws_caller_identity" "current" {}

resource "helm_release" "aws-cluster-autoscaler" {
  name  = "aws-cluster-autoscaler"
  chart = "stable/cluster-autoscaler"
  namespace = "kube-system"
  
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }
  set {
    name  = "extraArgs.expander"
    value = "most-pods"
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "rbac.pspEnabled"
    value = "true"
  }
  set {
    name  = "awsRegion"
    value = var.aws_region
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "podAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
    value = "false"
    type  = "string"
  }
  set {
    name  = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "k8s-${var.cluster_name}-autoscaler-role"
    type  = "string"

  }
  
  depends_on = [var.helm_depends_on]
}
