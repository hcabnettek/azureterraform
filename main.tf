# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.46.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ck_rg" {
  name     = "ckResourceGroup"
  location = "westus2"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_group" "ck_sg" {
  name                = "ck-security-group"
  location            = azurerm_resource_group.ck_rg.location
  resource_group_name = azurerm_resource_group.ck_rg.name
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "ck_sg_rule1" {
  name                        = "dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "68.8.178.101/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ck_rg.name
  network_security_group_name = azurerm_network_security_group.ck_sg.name
}


resource "azurerm_virtual_network" "ck_vn" {
  name                = "ck-vn-network"
  location            = azurerm_resource_group.ck_rg.location
  resource_group_name = azurerm_resource_group.ck_rg.name
  address_space       = ["10.123.0.0/16"]
  dns_servers         = ["10.123.0.4", "10.123.0.5"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "ck_sb1" {
  name                 = "ck_subnet1"
  resource_group_name  = azurerm_resource_group.ck_rg.name
  virtual_network_name = azurerm_virtual_network.ck_vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_subnet" "ck_sb2" {
  name                 = "ck_subnet2"
  resource_group_name  = azurerm_resource_group.ck_rg.name
  virtual_network_name = azurerm_virtual_network.ck_vn.name
  address_prefixes     = ["10.123.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.ck_sb1.id
  network_security_group_id = azurerm_network_security_group.ck_sg.id
}