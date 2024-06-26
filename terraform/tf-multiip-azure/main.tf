provider "azurerm" {
  features {}
}
variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
  default     = "East US"
  
}

variable "rg_name" {
  description = "The Azure Resource group bane."
  type        = string
  default     = "pubips-resources"
  
}

variable "num_ip_configs" {
  description = "The number of IP configurations to create."
  type        = number
  default     = 20
}

variable "admin_ssh_key" {
  description = "The initial ssh key."
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIOxg+goSYoCIND3IIAjPoPGr7gsux9OQjE5IP2wEU8eMsywgGXBwZXUVjh8NgFHVWZEMTQCAM52P2ipYBup9QhuqWVjH4v0hrj1X/rx7tzlZh2wk3kgVPQwMKCyacQLifqus4quJLSQAPu1ksgxaWEBWnSa0e+DM2D0PYs/j284qOO9T9ULqpb/ZJK9gySa+AfSMhGCskcT/EfE8g1iqC96PajFxGHOBxqiDFtIKPhNiqKYruDhVJYmhAXG6ScHadiXzP3BdiPR66eyCOQtSeIxjnEeJcrZ7vZLFpWQvaaZw+JfPkGGFCsBTn39dfr1awrMtPIPvkj4iU1jkGKzUD alessandro@Alessandros-MBP.fritz.box"
}

variable "address_space" {
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  default = ["10.0.1.0/24"]
}

resource "azurerm_resource_group" "pubips" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "pubips-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.pubips.location
  resource_group_name = azurerm_resource_group.pubips.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "pubips-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.pubips.name
  address_prefixes     = var.subnet_prefixes
}

resource "azurerm_public_ip" "public_ips" {
  
    count               = var.num_ip_configs
    name                = "pubip-${count.index + 1}"
    location            = azurerm_resource_group.pubips.location
    resource_group_name = azurerm_resource_group.pubips.name
    allocation_method   = "Dynamic"
    sku                 = "Basic"

}

resource "azurerm_network_interface" "vnet-nic" {
  name                = "vnet-nic"
  location            = azurerm_resource_group.pubips.location
  resource_group_name = azurerm_resource_group.pubips.name

  dynamic "ip_configuration" {
    for_each = range(var.num_ip_configs)

    content {
      name                          = "ipconfig-${ip_configuration.key + 1}"
      subnet_id                     = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.public_ips[ip_configuration.key].id
      primary                       = ip_configuration.key == 0 ? true : false
    }
  }
}

resource "azurerm_linux_virtual_machine" "proxy-vm" {
  name                = "proxy-vm"
  resource_group_name = azurerm_resource_group.pubips.name
  location            = azurerm_resource_group.pubips.location
  size                = "Standard_DS1_v2"
  admin_username      = "ubuntu"
  network_interface_ids = [azurerm_network_interface.vnet-nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble-daily"
    sku       = "24_04-daily-lts"
    version   = "latest"
  }
}

output "primary_public_ip" {
  value = azurerm_linux_virtual_machine.proxy-vm.public_ip_address
}