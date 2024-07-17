resource "azurerm_kubernetes_cluster" "aks" {
   location = var.location
   resource_group_name = var.resource_group_name
   node_resource_group = "${var.resource_group_name}-noderg"
   name = var.aks_name
   default_node_pool {
     name = "nodepool"
     node_count = "1"
     vm_size = "Standard_B2ms"
     vnet_subnet_id = var.aks_subnet
 }
   dns_prefix = "${var.aks_name}"
   identity {
     type = "SystemAssigned"
 }
   network_profile {
     network_plugin = "kubenet"
 }
   ingress_application_gateway{
     subnet_id = var.agw_subnet
 }
}

resource "azurerm_role_assignment" "agw-snet-contributor-for-ingress" {
   scope = var.vnet
   role_definition_name = "Contributor"
   principal_id = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
   depends_on = [
     azurerm_kubernetes_cluster.aks
   ]
}
