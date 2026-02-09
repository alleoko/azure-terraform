# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "Southeast Asia"
  tags = {
    environment = "dev"
  }
}
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVirtualNetwork"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}
resource "azurerm_subnet" "subnet" {
  name                 = "myTFSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.123.1.0/24"]

}
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    environment = "dev"
  }

}
resource "azurerm_network_security_rule" "nsg_rule" {
  name                        = "nsg_rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_public_ip" "public_ip" {
  name                = "myTFPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "dev"
  }
}
resource "azurerm_network_interface" "name" {
  name                = "myTFNetworkInterface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  tags = {
    environment = "dev"
  }
}
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "myTFLinuxVM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.name.id,
  ]

  custom_data = filebase64("customdata.tpl")

  /*Create a keypair = ssh-keygen -t rsa*/
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_tf_azure_rsakey.pub")
  }
  /*  to ssh instance =   */
  /* ssh -i ~/.ssh/id_tf_azure_rsakey adminuser@4.193.200.239 */

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "Ubuntu-server"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  provisioner "local-exec" {
      command = templatefile("linux-ssh-script.tpl", {
          hostname = self.public_ip_address,
          user = "adminuser",
          IdentityFile = "~/.ssh/id_tf_azure_rsakey"
      })
      interpreter = ["bash", "-c"]

  }

  tags = {
    environment = "dev"
  }
}
  data "azurerm_public_ip" "myTF_ip_data" {
    name                = azurerm_public_ip.public_ip.name
    resource_group_name = azurerm_resource_group.rg.name
  }
output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.vm.public_ip_address}: ${data.azurerm_public_ip.myTF_ip_data.ip_address}"
}
