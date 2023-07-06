locals {
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars
  prefix = "poc-accelerate-${random_string.naming.result}"
  dlsprefix = "pocaccelerate${random_string.naming.result}"
  tags = {
    owner = var.owner
  }
}

variable "owner" {
  description = "used for resource tagging"
}

variable "tags" {
  default = {}
}

variable "region" {
  default = "ap-southeast-2"
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

variable "no_public_ip" {
  type    = bool
  default = true
}

variable "rglocation" {
  type    = string
  default = "southeastasia"
}

variable "dbfs_prefix" {
  type    = string
  default = "dbfs"
}

variable "node_type" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "global_auto_termination_minute" {
  type    = number
  default = 30
}

variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}

