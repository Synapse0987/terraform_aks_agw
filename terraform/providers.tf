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

terraform {
   backend "azurerm" {
     storage_account_name = "akstftesting"
     container_name = "aks-tf"
     key = "terraform.tfstate"
  }
}
