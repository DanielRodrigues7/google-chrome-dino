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
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
    always_on        = true
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.acr.login_server}"
    WEBSITES_PORT              = "80"
  }
}

#############################################
# Permitir WebApp puxar a imagem do ACR
#############################################
resource "azurerm_role_assignment" "acr_pull_for_app" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}
