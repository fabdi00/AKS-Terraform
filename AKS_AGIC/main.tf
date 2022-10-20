resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# resource "azurerm_role_assignment" "role_acrpull" {
#   scope                            = azurerm_container_registry.acr.id
#   role_definition_name             = "AcrPull"
#   principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
#   skip_service_principal_aad_check = true
# }

# resource "azurerm_container_registry" "acr" {
#   name                = var.acr_name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   sku                 = "Standard"
#   admin_enabled       = false
# }
resource "azurerm_virtual_network" "test" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.virtual_network_address_prefix]

  subnet {
    name           = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name           = "appgwsubnet"
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  # subnet {
  #   name           = "mgmt"
  #   address_prefix = var.mgmt_subnet_address_prefix
  # }

  
}

data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.test]
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgwsubnet"
  virtual_network_name = azurerm_virtual_network.test.name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [azurerm_virtual_network.test]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "agentpool"
    node_count          = var.system_node_count
    vm_size             = "standard_d4s_v3"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1]
    enable_auto_scaling = false
    vnet_subnet_id  = data.azurerm_subnet.kubesubnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure" # CNI
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }
  
  role_based_access_control_enabled = true

  ingress_application_gateway {
    gateway_name = var.app_gateway_name
    subnet_id = data.azurerm_subnet.appgwsubnet.id
    
  }

  depends_on = [azurerm_virtual_network.test]
}