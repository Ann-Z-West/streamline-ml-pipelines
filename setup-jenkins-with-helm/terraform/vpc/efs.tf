# main.tf
resource "aws_efs_file_system" "devops_efs" {
  creation_token = "devops-efs"
  tags = {
    Name = "DevOpsEFS"
  }
}

resource "aws_efs_mount_target" "example_mount_target" {
  file_system_id  = aws_efs_file_system.devops_efs.id
  subnet_id       = var.vpc_private_subnets # Replace with your private subnet ID
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  description = "Allow NFS traffic to EFS"
  vpc_id      = data.aws_vpcs.devops.ids[0]

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.internal_cidrs] # Allow NFS from within your VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
