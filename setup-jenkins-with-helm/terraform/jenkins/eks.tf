data "aws_iam_role" "devops_eks_cluster" {
  name = "devops-eks-cluster-iam-role"
}

module "eks-cluster-policy" {
  source = "../modules/eks/"
}

resource "aws_eks_cluster" "devops" {
  name                      = "devops-eks-cluster"
  role_arn                  = data.aws_iam_role.devops_eks_cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids         = var.vpc_private_subnets # To be updated
    security_group_ids = var.sg_vpc_common # To be updated
    # Kubernetes API requests within your cluster's VPC (such as node to control plane communication) use the private VPC endpoint.
    endpoint_private_access = true
    endpoint_public_access  = false // Disable public access and there's no need to provide public access cidrs.
  }

  depends_on = [
    module.eks-cluster-policy.amazon-eks-cluster-policy,
    module.eks-cluster-policy.amazon-ebs-csi-driver-policy,
  ]

  tags = {
    Name = "devops-eks-cluster"
  }
}