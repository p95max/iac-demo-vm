resource "azurerm_resource_group" "this" {
  name     = "hylastix-rg"
  location = var.location
}