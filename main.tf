
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

resource "azurerm_subnet" "sn" {
  name                 = "${local.resource_prefix}-sn"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_container_registry" "acr" {
  name                = "ACR2DND549"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
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
    # vm_size         = "Standard_B2ls_v2"
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = azurerm_subnet.sn.id
    os_disk_size_gb = 30
    # temporary_name_for_rotation = "tempnodepool"
  }


  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
  }
}
resource "azurerm_kubernetes_cluster_node_pool" "workerpool" {
  name                  = "workerpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = 0.5
}

resource "azurerm_role_assignment" "aks-acr-role" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

