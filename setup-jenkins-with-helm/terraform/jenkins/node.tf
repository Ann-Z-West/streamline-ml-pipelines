data "aws_iam_role" "devops_nodes" {
  name = "devops-eks-node-group-general"
}

module "node-policy" {
  source = "../modules/node/"
}

locals {
  vms = {
    "jenkins" = {
      node_group_name        = "jenkins",
      subnet_ids             = [], # to be updated
      ami_type               = "AL2_x86_64",
      capacity_type          = "ON_DEMAND",
      instance_types         = "t3.small",
      desired_size           = 2,
      max_size               = 3,
      min_size               = 1,
      max_unavailable        = 1,
      force_update_version   = false,
      labels_role            = "jenkins",
      template_name          = "jenkins-node-with-disks",
      template_version       = "$Default",
      template_device_name   = "/dev/xvdb",
      template_volume_size   = 50,
      template_volume_type   = "gp3",
      template_resource_type = "instance",
      template_tags_name     = "jenkins-node"
    }
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.devops.name
  node_role_arn   = data.aws_iam_role.devops_nodes.arn
  for_each        = local.vms
  node_group_name = each.value.node_group_name

  subnet_ids = each.value.subnet_ids

  # Type of Amazon Machine Image (AMI) asscociated with the EKS Node Group.
  ami_type       = each.value.ami_type
  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  # Force version update if existing pods are unable to be drained due to pod disruption budget issue.
  force_update_version = each.value.force_update_version

  labels = {
    role = each.value.labels_role
  }

  launch_template {
    name    = each.value.template_name
    version = each.value.template_version
  }

  depends_on = [
    module.node-policy.nodes-amazon-eks-worker-node-policy,
    module.node-policy.nodes-amazon-eks-cni-policy,
    module.node-policy.nodes-amazon-ec2-container-registry-readonly,
    module.eks-cluster-policy.amazon-ebs-csi-driver-policy,
  ]
}

resource "aws_launch_template" "node-lt-staging" {
  for_each = local.vms
  name     = each.value.template_name

  block_device_mappings {
    device_name = each.value.template_device_name

    ebs {
      volume_size = each.value.template_volume_size
      volume_type = each.value.template_volume_type
    }
  }
  tag_specifications {
    resource_type = each.value.template_resource_type

    tags = {
      Name = each.value.template_tags_name
    }
  }
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 20
    instance_metadata_tags      = "disabled"
  }
}