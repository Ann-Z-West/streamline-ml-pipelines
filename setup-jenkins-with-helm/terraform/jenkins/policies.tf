resource "aws_iam_policy" "devops_iam_role_permission" {
  name        = "devops-iam-role-permission"
  description = "A policy to grant access to AWS resources"
  policy      = data.aws_iam_policy_document.neosight-iam-role-permission.json
}

data "aws_iam_policy_document" "neosight-iam-role-permission" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    condition {
      test     = "ArnEquals"
      variable = "ec2:Vpc"
      values   = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:vpc/${var.vpc_id}"]
    }
    resources = ["*"]
  }
}