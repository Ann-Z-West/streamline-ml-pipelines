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