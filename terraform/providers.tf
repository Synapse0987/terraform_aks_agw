terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.112.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.1.0"
}


provider "azurerm" {
  features {}
}

provider "helm" {
   kubernetes {
     host = azurerm_kubernetes_cluster.main.kube_config[0].host
     client_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
     client_key = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
     cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
  } 
}

terraform {
   backend "azurerm" {
     storage_account_name = "akstftesting"
     container_name = "aks-tf"
     key = "terraform.tfstate"
  }
}
