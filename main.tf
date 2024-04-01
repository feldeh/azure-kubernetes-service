
locals {
  resource_group_location = "northeurope"
  resource_prefix = "aks"
}

resource "azurerm_resource_group" "default" {
  name     = "${local.resource_prefix}-rg"
  location = local.resource_group_location
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "default" {
  name                = "${local.resource_prefix}-vn"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "default" {
  name                 = "${local.resource_prefix}-sn"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.123.1.0/24"]
}


