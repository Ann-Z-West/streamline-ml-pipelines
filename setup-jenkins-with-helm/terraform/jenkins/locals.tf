locals {
  k8s_service_account_name      = "jenkins"
  k8s_service_account_namespace = "devops"

  # Get the EKS OIDC Issuer without https:// prefix
  eks_oidc_issuer = trimprefix(aws_eks_cluster.devops.identity[0].oidc[0].issuer, "https://")
}