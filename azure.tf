locals {
  common_tags = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      workload    = "hcp-vault"
    },
    var.tags
  )

  vm_custom_data = base64encode(<<-EOT
    #cloud-config
    package_update: true
    packages:
      - curl
      - jq
      - unzip
      - dnsutils
  EOT
  )
}

data "external" "vm_ssh_key" {
  program = [
    "/bin/sh",
    "${path.module}/scripts/ensure_ssh_key.sh",
    "${path.root}/${var.azure_vm_private_key_filename}",
  ]
}

resource "azurerm_resource_group" "this" {
  name     = var.azure_resource_group_name
  location = var.azure_location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "this" {
  name                = var.azure_vnet_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.azure_vnet_cidr]
  tags                = local.common_tags
}

resource "azurerm_subnet" "compute" {
  name                 = var.azure_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.azure_subnet_cidr]
}

resource "azurerm_network_security_group" "compute" {
  name                = "${var.name_prefix}-compute-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ssh_allowed_cidrs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-vault-outbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = var.hvn_cidr_block
  }
}

resource "azurerm_subnet_network_security_group_association" "compute" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.compute.id
}

resource "azurerm_public_ip" "vm" {
  count = var.create_vm_public_ip ? 1 : 0

  name                = "${var.name_prefix}-vm-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.name_prefix}-vm-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.compute.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.create_vm_public_ip ? azurerm_public_ip.vm[0].id : null
    primary                       = true
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.azure_vm_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.azure_vm_size
  admin_username      = var.azure_vm_admin_username
  custom_data         = local.vm_custom_data
  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]
  tags = local.common_tags

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.azure_vm_admin_username
    public_key = trimspace(data.external.vm_ssh_key.result.public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
