provider "Azurerm"{
    version = ">=1.5"
}
terraform {
  required_version = ">= 0.12"
}

#ResourceGroup
resource "azurerm_resource_group" "RGEmmaX"{
    Name = "RG EmmaX"
    location = "easteurope"
}

#Virtual Network
resource "azurerm_virtual_network" "VNEmmaX"{
    name                = "EmmaX-network"
    address_space       = ["10.10.0.0/16"]
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
}

#Subnet
resource "azurerm_subnet" "SubnetEmmaX" {
  name                 = "EmmaX-Subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_interface" "NICEmmaX" {
  name                = "EmmaX-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "StaticConfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.3"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "Apache2"
  location              = azurerm_resource_group.RGEmmaX.location
  resource_group_name   = azurerm_resource_group.RGEmmaX.name
  network_interface_ids = [azurerm_network_interface.NICEmmaX.id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "FirstUbuntuVM"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "EmmaxSite"
    admin_username = "Admin"
    admin_password = "tnsio#1P"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}