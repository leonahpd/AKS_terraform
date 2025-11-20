#resource "azurerm_resource_group" "kodekloud" {
#  name     = "kml_rg_main-055825e7de90413f"
#  location = "East US"
#}

data "azurerm_resource_group" "testrse" {
  name = var.resource_group_name
}


#### create Virual Network #####

resource "azurerm_virtual_network" "vnet" {
  name                = "my-aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.testrse.location
  resource_group_name = data.azurerm_resource_group.testrse.name
}


#### create AKS network's subnet #####


resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = data.azurerm_resource_group.testrse.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#### create application gateway network's subnet #####

resource "azurerm_subnet" "agw_subnet" {
  name                 = "agw-subnet"
  resource_group_name  = data.azurerm_resource_group.testrse.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#### create application gateway public IP #####

resource "azurerm_public_ip" "agw_public_ip" {
  name                = "my-agw-public-ip"
  #location            = azurerm_kubernetes_cluster.kubernetes_aks2.location
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.testrse.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


#### create application gateway #######

resource "azurerm_application_gateway" "agw" {
  name                = "my-application-gateway"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.testrse.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.agw_public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    pick_host_name_from_backend_address  = true
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

### USE LOCAL to REUSE the EXPRESSION ###

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet.name}-rdrcfg"
}


#####AKS CLuster creation ########


resource "azurerm_kubernetes_cluster" "kubernetes_aks2" {
  name                = "Management_AKS"
  location            = "East US"
  resource_group_name = data.azurerm_resource_group.testrse.name
  dns_prefix          = "kkaks1"

  default_node_pool {
    name       = "worker"
    node_count = 1
    vm_size    = "Standard_dc2ads_v5"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }
#  service_principal {
#    client_id     = var.client_id
#    client_secret = var.client_secret
#  }
  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "10.1.0.10"
    service_cidr       = "10.1.0.0/16"

  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "test"
  }


  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.agw.id
  }

  
}  


output "management_client_certificate" {
  value     = azurerm_kubernetes_cluster.kubernetes_aks2.kube_config[0].client_certificate
  sensitive = true
}

output "management_kube_config" {
  value = azurerm_kubernetes_cluster.kubernetes_aks2.kube_config_raw

  sensitive = true
}


