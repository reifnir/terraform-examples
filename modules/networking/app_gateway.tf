locals {
  # make local variables for values that are used more than once to denote clear association
  app_gateway_backend_pool_name = "${var.resource_name_base}-app-gateway-beap"
  backend_http_settings_name = "${var.resource_name_base}-be-htst"
  ssl_certificate_name = "${var.resource_name_base}-cert"
  public_frontend_ip_configuration_name = "${var.resource_name_base}-feip-public"
  private_frontend_ip_configuration_name = "${var.resource_name_base}-feip-private"
  https_frontend_port = "${var.resource_name_base}-ifeport-https"
  http_frontend_port = "${var.resource_name_base}-ifeport-http"
  backend_https_probe_healthz = "${var.resource_name_base}-healthz"
  http_listener_name = "${var.resource_name_base}-ihttplstn"
  https_listener_name = "${var.resource_name_base}-ihttpslstn"
  https_redirect_configuration_name = "${var.resource_name_base}-rdrcfg"
}

# Create Subnets for Application Gateway
resource "azurerm_subnet" "app_gateway" {
  name                 = "${var.resource_name_base}-app-gateway-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = [local.app_gateway_subnet_cidr]
}


# Create Public IP for Internal Gateway
resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-${var.resource_name_base}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create App Gateway Network Security Group
resource "azurerm_network_security_group" "app_gateway" {
  name                = "nsg-app-gateway-public"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags                = var.tags

  security_rule {
    name                       = "app-gateway-nsg-rule-inbound-http"
    priority                   = 100
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  # Only allow CloudFlare traffic when the gateway is intended to be externally accessible
  security_rule {
    name                       = "app-gateway-nsg-rule-inbound-https"
    priority                   = 110
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "gateway-nsg-rule-inbound-azure-internal-communication"
    priority                   = 200
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the App Gateway Network Security Group to the Subnet
resource "azurerm_subnet_network_security_group_association" "app_gateway_nsg_subnet_association" {
  subnet_id                 = azurerm_subnet.app_gateway.id
  network_security_group_id = azurerm_network_security_group.app_gateway.id
}

# Create an application gateway with SSL termination
resource "azurerm_application_gateway" "app_gateway" {
  name                = "ag-${var.resource_name_base}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags                = var.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.resource_name_base}-ipcfg"
    subnet_id = azurerm_subnet.app_gateway.id
  }

  ssl_certificate {
    name     = local.ssl_certificate_name
    data     = filebase64("${var.tls_cert_path}")
    password = var.tls_cert_password
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  frontend_ip_configuration {
    name                 = local.public_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  # Only map the private IP Address to the Default App Gateway when the swarm is exposed to the internet
  frontend_ip_configuration {
    name                          = local.private_frontend_ip_configuration_name
    private_ip_address            = local.app_gateway_private_ip
    private_ip_address_allocation = "Static"
    subnet_id                     = azurerm_subnet.app_gateway.id
  }

  # IP & Port Configurations
  frontend_port {
    name = local.https_frontend_port
    port = 443
  }

  frontend_port {
    name = local.http_frontend_port
    port = 80
  }

  # Backend Pool Configuration
  backend_address_pool {
    name = local.app_gateway_backend_pool_name
  }

  probe {
    name                                      = local.backend_https_probe_healthz
    host                                      = var.health_check_hostname
    protocol                                  = "Https"
    path                                      = "/healthz"
    pick_host_name_from_backend_http_settings = "false"
    interval                                  = "60"
    timeout                                   = "30"
    unhealthy_threshold                       = "2"
    match {
      body        = "OK"
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                                = local.backend_http_settings_name
    cookie_based_affinity               = "Disabled"
    port                                = var.https_listening_port
    protocol                            = "Https"
    request_timeout                     = var.gateway_request_timeout
    pick_host_name_from_backend_address = "false"
    probe_name                          = local.backend_https_probe_healthz
  }

  # HTTPS Listener
  http_listener {
    name                           = local.https_listener_name
    frontend_ip_configuration_name = local.public_frontend_ip_configuration_name
    frontend_port_name             = local.https_frontend_port
    protocol                       = "Https"
    ssl_certificate_name           = local.ssl_certificate_name
    # custom_error_configuration {
    #   status_code           = "HttpStatus502"
    #   custom_error_page_url = "https://samaintenancepage.z13.web.core.windows.net/index.html"
    # }
  }

  #  HTTP Listener - used for redirect rule
  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.public_frontend_ip_configuration_name
    frontend_port_name             = local.http_frontend_port
    protocol                       = "Http"
  }

  redirect_configuration {
    name                 = local.https_redirect_configuration_name
    redirect_type        = "Permanent"
    target_listener_name = local.https_listener_name
    include_path         = "true"
    include_query_string = "true"
  }

  # Request Routing Rules
  request_routing_rule {
    name                        = "${var.resource_name_base}-http-to-https"
    rule_type                   = "Basic"
    http_listener_name          = local.http_listener_name
    redirect_configuration_name = local.https_redirect_configuration_name
  }

  request_routing_rule {
    name                       = "${var.resource_name_base}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = local.https_listener_name
    backend_address_pool_name  = local.app_gateway_backend_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }
}
