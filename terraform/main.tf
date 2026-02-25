resource "azurerm_resource_group" "main" {
  name     = "hylastix-rg"
  location = var.location
}