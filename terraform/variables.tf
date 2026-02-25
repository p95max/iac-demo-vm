variable "location" {
  default = "westeurope"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "azureuser"
}

variable "public_key_path" {
  description = "Path to SSH public key"
}