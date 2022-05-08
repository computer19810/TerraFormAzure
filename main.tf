# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
     resource_group {
      prevent_deletion_if_contains_resources = false

    }
  }
}
resource "azurerm_resource_group" "Zhttfrg" {
    name = "ZhtResourceGroup"
    location = "eastasia"
    tags = {
        environment = "My Terraform Demo"
    }   
}
resource "azurerm_virtual_network" "Zhttfnetwork" {
    name                = "ZhtVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.Zhttfrg.name}"

    tags = {
        environment = "My Terraform Demo"
    }
}
resource "azurerm_subnet" "Zhttfsubnet" {
    name                 = "ZhtSubnet"
    resource_group_name  = "${azurerm_resource_group.Zhttfrg.name}"
    virtual_network_name = "${azurerm_virtual_network.Zhttfnetwork.name}"
    #address_prefix       = "10.0.2.0/24"
    address_prefixes     = ["10.0.2.0/24"]
}
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.Zhttfrg.name}"
    }

    byte_length = 8
}
resource "azurerm_network_interface" "Zhttfnic" {
    name                = "ZhtNIC"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.Zhttfrg.name}"
    #network_security_group_id = "${azurerm_network_security_group.Zhttfnsg.id}"

    ip_configuration {
        name                          = "ZhtNicConfiguration"
        subnet_id                     = "${azurerm_subnet.Zhttfsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.Zhttfpublicip.id}"
    }

    tags = {
        environment = "My Terraform Demo"
    }
}
resource "azurerm_storage_account" "Zhttfstorageaccount" {
    name                = "zhtsa${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.Zhttfrg.name}"
    location            = "eastasia"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags = {
        environment = "My Terraform Demo"
    }
}

resource "azurerm_public_ip" "Zhttfpublicip" {
    name                         = "ZhtPublicIP"
    location                     = "eastasia"
    resource_group_name          = "${azurerm_resource_group.Zhttfrg.name}"
    allocation_method            = "Dynamic"

    tags = {
        environment = "My Terraform Demo"
    }
}
resource "azurerm_network_security_group" "Zhttfnsg" {
    name                = "ZhtNetworkSecurityGroup"
    location            = "eastasia"
    resource_group_name = "${azurerm_resource_group.Zhttfrg.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "My Terraform Demo"
    }
}
resource "azurerm_virtual_machine" "Zhttfvm" {
    
  name                  = "ZhtVM"
  location              = "eastasia"
  resource_group_name   = "${azurerm_resource_group.Zhttfrg.name}"
  network_interface_ids = ["${azurerm_network_interface.Zhttfnic.id}"]
  vm_size               = "Standard_DS1_v2"


  storage_os_disk {
        name              = "ZhtOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

  storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }
  
  os_profile {
        computer_name  = "phoenix"
        admin_username = "Zht"
    }
  os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/Zht/.ssh/authorized_keys"
            key_data = "****************************************************************************8"
        }
  }
  tags = {
    environment = "My Terraform Demo"
  }
}