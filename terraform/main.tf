module "az_rg_vn" {
   source = "./modules/rg_vn"
   location = var.location
}

module "az_aks" {
   source = "./modules/aks"
   location = var.location
   resource_group_name = module.az_rg_vn.rg
   aks_name = "${var.location}-assignment-aks"
   aks_subnet = module.az_rg_vn.aks_subnet.id
   agw_subnet = module.az_rg_vn.agw_subnet.id
   vnet = module.az_rg_vn.vnet.id
}
