provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "haven" {
  name     = "${var.clustername}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "haven" {
  name                = "${var.clustername}-vnet"
  location            = azurerm_resource_group.haven.location
  resource_group_name = azurerm_resource_group.haven.name
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.haven.name
  resource_group_name  = azurerm_resource_group.haven.name
  address_prefixes     = ["10.254.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "haven" {
  name                    = var.clustername
  location                = azurerm_resource_group.haven.location
  dns_prefix              = var.clustername
  private_cluster_enabled = var.private_cluster_enabled
  resource_group_name     = azurerm_resource_group.haven.name
  node_resource_group     = "${var.clustername}-aks-rg"

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
    }
  }

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_size
    vnet_subnet_id      = azurerm_subnet.default.id
    max_pods            = var.max_pods
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.auto_scaling_min_count : null
    max_count           = var.enable_auto_scaling ? var.auto_scaling_max_count : null
    availability_zones  = [1, 2, 3]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled = false
    }
  }
}
