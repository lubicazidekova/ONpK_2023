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

variable "project" {
  type = string
}


variable "external_network_name" {
  type    = string
}

variable "external_network_subnet_name" {
  type    = string
}
variable "private_network_name" {
  type    = string
}
variable "private_network_subnet_name" {
  type    = string
}


variable "router_name" {
  type = string
}
variable "JUMP_SG_name" {
  type = string
}
variable "MINIKUBE_SG_name" {
  type = string
}

variable "JUMP_instance_name" {
  type=string
}
variable "MINIKUBE_instance_name" {
  type=string
}