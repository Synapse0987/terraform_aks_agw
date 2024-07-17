variable "location" {
   type = string
   description = "Southeastasia region"
}

variable "resource_group_name"{
   type = string
   description = "Resource group name"
}

variable "aks_name" {
   type = string
   description = "AKS name"
}

variable "aks_subnet" {
   type = string
   description = "AKS subnet for node pool as defined in rg_nv main.tf"
}

variable "agw_subnet" {
   type = string
   description = "AGW subnet for application gateway as defined in rg_nv main.tf"
}

variable "vnet" {
   type = string
   description = "Vnet as defined in rg_nv main.tf"
}
