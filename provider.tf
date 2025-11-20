
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
#  skip_provider_registration = true
  resource_provider_registrations = "none"
  subscription_id = "708bb9e2-34c3-4950-87fe-3048e133476e"
  tenant_id       = "30fe8ff1-adc6-444d-ba94-1238894df42c"
#  client_id       = "<add client ID >"
#  client_secret   = "<add secret >"

}

