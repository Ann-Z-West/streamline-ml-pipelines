/* All of the policy attachements are independent of the environment.
* Each resource below is declared only once.
*/
data "aws_iam_role" "devops_eks_cluster" {
  name = "devops-eks-cluster-iam-role"
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = data.aws_iam_role.devops_eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "amazon-ebs-csi-driver-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = data.aws_iam_role.devops_eks_cluster.name
}