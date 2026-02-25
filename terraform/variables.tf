variable "location" {
  default = "northeurope"
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  default = "azureuser"
}

variable "public_key_path" {
  description = "Path to SSH public key"
}