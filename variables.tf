# --- variables.tf ---

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "tenant_name" {
  type = string
}

# Default: ext-net (External network -> instance connection to internet)
variable "external_network_name" {
  type    = string
  default = "ext-net"
}

variable "private_network_name" {
  type    = string
  default = "my-net"
}

variable "project" {
  type = string
}

variable "environment_private" {
  type = string
}

variable "environment_public" {
  type = string
}