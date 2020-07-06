locals {
  # TODO: Need to add random_id hex here, keepers are removed from azurerm 2x
  config_file_path     = "${path.module}/cloud-init.yaml"
  vm_hostname          = "${var.resource_name_base}-backend-${var.vm_id}-${random_id.id.hex}"
  nic_ip_configuration = "${local.vm_hostname}-nic-cfg"
}

resource "random_id" "id" {
  byte_length = 2
  keepers = {
    config_file_hash = filemd5(local.config_file_path)
  }
}

data "template_file" "cloud_init" {
  template = file(local.config_file_path)

  vars = {
    https_listening_port    = var.https_listening_port
    cert-public             = "${file("../../cert/cert-public.pem")}"
    cert-private            = "${file("../../cert/cert-private.pem")}"
  }
}

data "template_cloudinit_config" "vm" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-init.tpl"
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloud_init.rendered}"
  }
}

resource "azurerm_public_ip" "vm" {
  name                = "pip-${local.vm_hostname}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm" {
  name                = "${local.vm_hostname}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = local.nic_ip_configuration
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vm-nic-beap-association" {
  network_interface_id    = azurerm_network_interface.vm.id
  ip_configuration_name   = local.nic_ip_configuration
  backend_address_pool_id = var.app_gateway_backend_pool_id
}

resource "azurerm_network_security_group" "vm" {
    name                = "nsg-${local.vm_hostname}"
    location            = var.location
    resource_group_name = var.resource_group_name
    
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

    tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "vm" {
    network_interface_id      = azurerm_network_interface.vm.id
    network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                = local.vm_hostname
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_sku

  admin_username                  = var.admin_username
  disable_password_authentication = true

  availability_set_id = var.vm_availability_set_id
  network_interface_ids = [ azurerm_network_interface.vm.id ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.data_disk_size_in_gb
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = var.diag_storage_account_endpoint
  }

  tags = var.tags
}


# var.health_check_hostname
