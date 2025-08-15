variable "profile" {
  description = "AWS profile name"
  type        = string
  default     = "super-annz"
}

variable "credentials" {
  description = "AWS credentials for service account"
  default     = ["$HOME/.aws/credentials"]
}

variable "owner" {
  description = "The email address to be used in the OWNER tag."
  type        = string

  validation {
    condition     = substr(var.owner, -10, -1) == "@gmail.com"
    error_message = "The input value must be a valid email address, ending with @gmail.com."
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  default = "" # replace with VPC ID
}

variable "sg_vpc_common" {
  description = "ID of the vpc-common security group"
  default     = [] # get the group ID once the VPC and its security group is created
}

variable "vpc_private_subnets" {
  description = "The private subnets associated with the VPC"
  default     = []
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.31.3-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.19.3-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.11.4-eksbuild.2"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.40.0-eksbuild.1"
    }
  ]
}
