#############################################
# Resource Group
#############################################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

#############################################
# App Service Plan (Linux)
#############################################
resource "azurerm_service_plan" "plan" {
  name                = "${var.prefix}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

#############################################
# Azure Container Registry (ACR)
#############################################
resource "azurerm_container_registry" "acr" {
  name                = replace("${var.prefix}acr", "/[^a-z0-9]/", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

#############################################
# Web App Linux rodando Docker (provider 4.x)
#############################################
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-web"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.acr.login_server}/${var.image_name}"
      docker_image_tag = var.image_tag
    }
  }

  app_settings = {
    WEBSITES_PORT = "80"
  }
}

#############################################
# Permitir o Web App puxar imagem do ACR
#############################################
resource "azurerm_role_assignment" "acr_pull_for_app" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azur
