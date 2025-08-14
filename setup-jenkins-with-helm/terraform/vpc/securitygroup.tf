resource "aws_security_group" "standard_internal" {
  name        = "standard-internal"
  description = "All standard allowed internal traffic"
  vpc_id      = data.aws_vpcs.devops.ids[0]

  tags = {
    Name = "standard-internal"
  }

}

# Standard ports that are allowed by default and any custom ports
#
# 3389_tcp (RDP - Microsoft Remote Desktop)
# junos-https (tcp 443)
# junos-ssh (tcp 22)
# junos-icmp-all (ping)

resource "aws_security_group_rule" "egress_any" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.standard_internal.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_icmp_all" {
  cidr_blocks       = var.internal_cidrs
  from_port         = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.standard_internal.id
  to_port           = -1
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_ssh" {
  cidr_blocks       = var.internal_cidrs
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.standard_internal.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_https" {
  cidr_blocks       = var.internal_cidrs
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.standard_internal.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_rdp" {
  cidr_blocks       = var.internal_cidrs
  from_port         = 3389
  protocol          = "tcp"
  security_group_id = aws_security_group.standard_internal.id
  to_port           = 3389
  type              = "ingress"
}
