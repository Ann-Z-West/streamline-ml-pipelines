variable "internal_cidrs" {
  description = "Internal CIDRs for trusted hosts"

  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

variable "owner" {
  description = "The email address to be used in the OWNER tag."
  type        = string
}
