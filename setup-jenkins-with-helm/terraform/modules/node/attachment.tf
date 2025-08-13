/* All of the policy attachements are independent of the environment.
* Each resource below is declared only once.
*/

data "aws_iam_role" "devops_node" {
  name = "devops-eks-node-group-general"
}

data "aws_iam_role" "devops_eks" {
  name = "devops-eks-cluster-iam-role"
}

resource "aws_iam_role_policy_attachment" "nodes-amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = data.aws_iam_role.devops_node.name
}

resource "aws_iam_role_policy_attachment" "nodes-amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = data.aws_iam_role.devops_node.name
}

resource "aws_iam_role_policy_attachment" "nodes-amazon-ec2-container-registry-readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = data.aws_iam_role.devops_node.name
}

resource "aws_iam_role_policy_attachment" "nodes-amazon-ebs-csi-driver-policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = data.aws_iam_role.devops_node.name
}