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
    container_registry_use_managed_identity = true

    container_settings {
      image_name = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
    }
  }

  app_settings = {
    WEBSITES_PORT = "80"
  }
}
