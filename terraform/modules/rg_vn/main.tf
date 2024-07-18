resource "azurerm_resource_group" "terraform_rg" {
   location = var.location
   name = "rg-${var.location}-aks-cluster"
}

resource "azurerm_virtual_network" "vnet" {
   location = var.location
   resource_group_name = azurerm_resource_group.terraform_rg.name
   name = "${var.location}-setup-vnet"
   address_space = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
   resource_group_name = azurerm_resource_group.terraform_rg.name
   name = "aks-subnet"
   virtual_network_name = azurerm_virtual_network.vnet.name
   address_prefixes = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "agw_subnet" {
   resource_group_name = azurerm_resource_group.terraform_rg.name
   name = "agw-subnet"
   virtual_network_name = azurerm_virtual_network.vnet.name
   address_prefixes = ["10.2.2.0/24"]
}

resource "azurerm_log_analytics_workspace" "law" {
   name = "tf-law"
   location = var.location
   resource_group_name = azurerm_resource_group.terraform_rg.name
   sku = "PerGB2018"
   retention_in_days = 30
}


output "aks_subnet" { value = azurerm_subnet.aks_subnet }
output "agw_subnet" { value = azurerm_subnet.agw_subnet }
output "vnet" { value = azurerm_virtual_network.vnet }
output "rg" { value = azurerm_resource_group.terraform_rg.name }
output "law" { value = azurerm_log_analytics_workspace.law.id }
