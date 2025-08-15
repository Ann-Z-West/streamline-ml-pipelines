resource "aws_iam_role" "devops_eks_cluster" {
  name = "devops-eks-cluster-iam-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role" "devops_nodes" {
  name = "devops-eks-node-group-general"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Create the IAM role that will be assumed by the service account
resource "aws_iam_role" "devops_service_role" {
  name               = "devops-service-role"
  assume_role_policy = data.aws_iam_policy_document.devops_service_role_assume_policy.json
}

# Create IAM policy allowing the k8s service account to assume the IAM role
data "aws_iam_policy_document" "devops_service_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
      ]
    }

    # Limit the scope so that only our desired service account can assume this role
    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer}:sub"
      values = [
        "system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"
      ]
    }
  }
}

data "aws_iam_policy" "devops_iam_role_permission" {
  name = "devops-iam-role-permission"
}

resource "aws_iam_role_policy_attachment" "neosight-iam-role-permission-policy-attach" {
  role       = aws_iam_role.devops_service_role.name
  policy_arn = data.aws_iam_policy.devops_iam_role_permission.arn
}