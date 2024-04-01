
locals {
  resource_prefix = "aks"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.resource_prefix}-rg"
  location = var.resource_group_location
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "vn" {
  name                = "${local.resource_prefix}-vn"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}


resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${local.resource_prefix}-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s"
  kubernetes_version  = var.kubernetes_version

  sku_tier = "Free"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "agentpool"
    node_count      = 1
    vm_size         = "Standard_B2ls_v2"
    os_disk_size_gb = 30
  }
  
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }
}


