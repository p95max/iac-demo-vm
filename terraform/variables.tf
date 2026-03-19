variable "location" {
  type    = string
  default = "northeurope"
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
}