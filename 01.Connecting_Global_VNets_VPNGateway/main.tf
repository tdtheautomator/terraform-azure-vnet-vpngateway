# VNet to VNet VPN Gateway
# ---------------------- Define Providers----------------------
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  required_version = ">= 0.14.10"
}
provider "azurerm" {
  features {}
}

# ---------------------- Resource Groups ----------------------
resource "azurerm_resource_group" "rg04-eastus2" {
  name     = "rg04-eastus2"
  location = "eastus2"
}
resource "azurerm_resource_group" "rg05-centralus" {
  name     = "rg05-centralus"
  location = "centralus"
}
resource "azurerm_resource_group" "rg06-westus2" {
  name     = "rg06-westus2"
  location = "westus2"
}

# ---------------------- Virtual Networks ----------------------
resource "azurerm_virtual_network" "vnet04-eastus2" {
  name                = "vnet04-eastus2"
  location            = azurerm_resource_group.rg04-eastus2.location
  resource_group_name = azurerm_resource_group.rg04-eastus2.name
  address_space       = ["10.10.0.0/16"]
}
resource "azurerm_virtual_network" "vnet05-centralus" {
  name                = "vnet05-centralus"
  location            = azurerm_resource_group.rg05-centralus.location
  resource_group_name = azurerm_resource_group.rg05-centralus.name
  address_space       = ["10.20.0.0/16"]
}
resource "azurerm_virtual_network" "vnet06-westus2" {
  name                = "vnet06-westus2"
  location            = azurerm_resource_group.rg06-westus2.location
  resource_group_name = azurerm_resource_group.rg06-westus2.name
  address_space       = ["10.30.0.0/16"]
}

# ---------------------- VM Subnets ----------------------
resource "azurerm_subnet" "default-subnet-vnet04" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.rg04-eastus2.name
  virtual_network_name = azurerm_virtual_network.vnet04-eastus2.name
  address_prefixes     = ["10.10.10.0/24"]
}
resource "azurerm_subnet" "default-subnet-vnet05" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.rg05-centralus.name
  virtual_network_name = azurerm_virtual_network.vnet05-centralus.name
  address_prefixes     = ["10.20.20.0/24"]
}
resource "azurerm_subnet" "default-subnet-vnet06" {
  name                 = "default-subnet"
  resource_group_name  = azurerm_resource_group.rg06-westus2.name
  virtual_network_name = azurerm_virtual_network.vnet06-westus2.name
  address_prefixes     = ["10.30.30.0/24"]
}

# ---------------------- Gateway Subnets ----------------------
resource "azurerm_subnet" "gatewaysubnet-vnet04" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg04-eastus2.name
  virtual_network_name = azurerm_virtual_network.vnet04-eastus2.name
  address_prefixes     = ["10.10.40.0/27"]
}
resource "azurerm_subnet" "gatewaysubnet-vnet05" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg05-centralus.name
  virtual_network_name = azurerm_virtual_network.vnet05-centralus.name
  address_prefixes     = ["10.20.40.0/27"]
}
resource "azurerm_subnet" "gatewaysubnet-vnet06" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg06-westus2.name
  virtual_network_name = azurerm_virtual_network.vnet06-westus2.name
  address_prefixes     = ["10.30.40.0/27"]
}

# ---------------------- Network Security Groups ----------------------
resource "azurerm_network_security_group" "nsg04-eastus2" {
  name                = "nsg04-eastus2"
  location            = azurerm_resource_group.rg04-eastus2.location
  resource_group_name = azurerm_resource_group.rg04-eastus2.name
}
resource "azurerm_network_security_group" "nsg05-centralus" {
  name                = "nsg05-centralus"
  location            = azurerm_resource_group.rg05-centralus.location
  resource_group_name = azurerm_resource_group.rg05-centralus.name
}
resource "azurerm_network_security_group" "nsg06-westus2" {
  name                = "nsg06-westus2"
  location            = azurerm_resource_group.rg06-westus2.location
  resource_group_name = azurerm_resource_group.rg06-westus2.name
}

# ---------------------- Network Security Rules ----------------------
resource "azurerm_network_security_rule" "allow-in-ssh-nsg04" {
  name                        = "allow-ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg04-eastus2.name
  network_security_group_name = azurerm_network_security_group.nsg04-eastus2.name
}
resource "azurerm_network_security_rule" "allow-in-ssh-nsg05" {
  name                        = "allow-ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg05-centralus.name
  network_security_group_name = azurerm_network_security_group.nsg05-centralus.name
}
resource "azurerm_network_security_rule" "allow-in-ssh-nsg06" {
  name                        = "allow-ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg06-westus2.name
  network_security_group_name = azurerm_network_security_group.nsg06-westus2.name
}

# ---------------------- Associate VM Subnets to Network Security Groups ----------------------
resource "azurerm_subnet_network_security_group_association" "default-subnet-vnet04-nsg04" {
  subnet_id                 = azurerm_subnet.default-subnet-vnet04.id
  network_security_group_id = azurerm_network_security_group.nsg04-eastus2.id
}
resource "azurerm_subnet_network_security_group_association" "default-subnet-vnet05-nsg05" {
  subnet_id                 = azurerm_subnet.default-subnet-vnet05.id
  network_security_group_id = azurerm_network_security_group.nsg05-centralus.id
}
resource "azurerm_subnet_network_security_group_association" "default-subnet-vnet06-nsg06" {
  subnet_id                 = azurerm_subnet.default-subnet-vnet06.id
  network_security_group_id = azurerm_network_security_group.nsg06-westus2.id
}

# ---------------------- VM Public IPs ----------------------
resource "azurerm_public_ip" "vm04-pubip01" {
  name                    = "vm04-pubip01"
  location                = azurerm_resource_group.rg04-eastus2.location
  resource_group_name     = azurerm_resource_group.rg04-eastus2.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}
resource "azurerm_public_ip" "vm05-pubip01" {
  name                    = "vm05-pubip01"
  location                = azurerm_resource_group.rg05-centralus.location
  resource_group_name     = azurerm_resource_group.rg05-centralus.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}
resource "azurerm_public_ip" "vm06-pubip01" {
  name                    = "vm06-pubip01"
  location                = azurerm_resource_group.rg06-westus2.location
  resource_group_name     = azurerm_resource_group.rg06-westus2.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

# ---------------------- VM NICs ----------------------
resource "azurerm_network_interface" "vm04-nic01" {
  name                = "vm04-nic01"
  location            = azurerm_resource_group.rg04-eastus2.location
  resource_group_name = azurerm_resource_group.rg04-eastus2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default-subnet-vnet04.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm04-pubip01.id
  }
}
resource "azurerm_network_interface" "vm05-nic01" {
  name                = "vm05-nic01"
  location            = azurerm_resource_group.rg05-centralus.location
  resource_group_name = azurerm_resource_group.rg05-centralus.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default-subnet-vnet05.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm05-pubip01.id
  }
}
resource "azurerm_network_interface" "vm06-nic01" {
  name                = "vm06-nic01"
  location            = azurerm_resource_group.rg06-westus2.location
  resource_group_name = azurerm_resource_group.rg06-westus2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default-subnet-vnet06.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm06-pubip01.id
  }
}

# ---------------------- Linux VMs ----------------------
resource "azurerm_linux_virtual_machine" "vm04" {
  name                            = "vm04"
  resource_group_name             = azurerm_resource_group.rg04-eastus2.name
  location                        = azurerm_resource_group.rg04-eastus2.location
  size                            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "vmadmin"
  admin_password                  = "P@ssword.123"
  network_interface_ids           = [
              azurerm_network_interface.vm04-nic01.id,
            ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "vm05" {
  name                            = "vm05"
  resource_group_name             = azurerm_resource_group.rg05-centralus.name
  location                        = azurerm_resource_group.rg05-centralus.location
  size                            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "vmadmin"
  admin_password                  = "P@ssword.123"
  network_interface_ids           = [
              azurerm_network_interface.vm05-nic01.id,
            ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "vm06" {
  name                            = "vm06"
  resource_group_name             = azurerm_resource_group.rg06-westus2.name
  location                        = azurerm_resource_group.rg06-westus2.location
  size                            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "vmadmin"
  admin_password                  = "P@ssword.123"
  network_interface_ids           = [
              azurerm_network_interface.vm06-nic01.id,
            ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

# ---------------------- Gateway Public IPs ----------------------
resource "azurerm_public_ip" "vgw-pubip01-vnet04" {
  name                    = "vgw-pubip01-vnet04"
  location                = azurerm_resource_group.rg04-eastus2.location
  resource_group_name     = azurerm_resource_group.rg04-eastus2.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}
resource "azurerm_public_ip" "vgw-pubip01-vnet05" {
  name                    = "vgw-pubip01-vnet05"
  location                = azurerm_resource_group.rg05-centralus.location
  resource_group_name     = azurerm_resource_group.rg05-centralus.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}
resource "azurerm_public_ip" "vgw-pubip01-vnet06" {
  name                    = "vgw-pubip01-vnet06"
  location                = azurerm_resource_group.rg06-westus2.location
  resource_group_name     = azurerm_resource_group.rg06-westus2.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
}

# ---------------------- Virtual Network Gateways ----------------------
resource "azurerm_virtual_network_gateway" "vng-vnet04" {
  name                = "vng-vnet04"
  location                = azurerm_resource_group.rg04-eastus2.location
  resource_group_name     = azurerm_resource_group.rg04-eastus2.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vgw-pubip01-vnet04.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet-vnet04.id
  }
}
resource "azurerm_virtual_network_gateway" "vng-vnet05" {
  name                = "vng-vnet05"
  location                = azurerm_resource_group.rg05-centralus.location
  resource_group_name     = azurerm_resource_group.rg05-centralus.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vgw-pubip01-vnet05.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet-vnet05.id
  }
}
resource "azurerm_virtual_network_gateway" "vng-vnet06" {
  name                = "vng-vnet06"
  location                = azurerm_resource_group.rg06-westus2.location
  resource_group_name     = azurerm_resource_group.rg06-westus2.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vgw-pubip01-vnet06.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet-vnet06.id
  }
}

# ---------------------- Virtual Network Gateway Connections ----------------------
resource "azurerm_virtual_network_gateway_connection" "conn_eastus2_centralus" {
  name                = "conn_eastus2_centralus"
  location            = azurerm_resource_group.rg04-eastus2.location
  resource_group_name = azurerm_resource_group.rg04-eastus2.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vng-vnet04.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-vnet05.id

  shared_key = "4-5h4r3d-k3y"
}
resource "azurerm_virtual_network_gateway_connection" "conn_centralus_eastus2" {
  name                = "conn_centralus_eastus2"
  location            = azurerm_resource_group.rg05-centralus.location
  resource_group_name = azurerm_resource_group.rg05-centralus.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vng-vnet05.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-vnet04.id

  shared_key = "4-5h4r3d-k3y"
}
resource "azurerm_virtual_network_gateway_connection" "conn_westus2_centralus" {
  name                = "conn_westus2_centralus"
  location            = azurerm_resource_group.rg06-westus2.location
  resource_group_name = azurerm_resource_group.rg06-westus2.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vng-vnet06.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-vnet05.id

  shared_key = "4-5h4r3d-k3y"
}
resource "azurerm_virtual_network_gateway_connection" "conn_centralus_westus2" {
  name                = "conn_centralus_westus2"
  location            = azurerm_resource_group.rg05-centralus.location
  resource_group_name = azurerm_resource_group.rg05-centralus.name

  type                            = "Vnet2Vnet"
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.vng-vnet05.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-vnet06.id

  shared_key = "4-5h4r3d-k3y"
}

# ---------------------- Outputs ----------------------
output "vm04-public-ip" {
  value = azurerm_linux_virtual_machine.vm04.public_ip_address
}
output "vm04-private-ip" {
  value = azurerm_linux_virtual_machine.vm04.private_ip_address
}
output "vm05-public-ip" {
  value = azurerm_linux_virtual_machine.vm05.public_ip_address
}
output "vm05-private-ip" {
  value = azurerm_linux_virtual_machine.vm05.private_ip_address
}
output "vm06-public-ip" {
  value = azurerm_linux_virtual_machine.vm06.public_ip_address
}
output "vm06-private-ip" {
  value = azurerm_linux_virtual_machine.vm06.private_ip_address
}
# -----------------------------------------------------