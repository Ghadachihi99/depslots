# Generate a random prefix
resource "random_string" "prefix" {
  length  = 5
  special = false
  upper   = false
}

# Define the Azure Resource Group for Web App
resource "azurerm_resource_group" "example" {
  name     = "${random_string.prefix.result}-my-resource-group"
  location = "West Europe"
}

# Define the App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "${random_string.prefix.result}-service-plan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

# Define the main Web App (Production)
resource "azurerm_windows_web_app" "example" {
  name                = "manebni"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

# Dev Slot
resource "azurerm_windows_web_app_slot" "dev" {
  name                = "dev"
  
  
  app_service_id      = azurerm_windows_web_app.example.id

  site_config {}
}

# Test Slot
resource "azurerm_windows_web_app_slot" "test" {
  name                = "test"
 
  app_service_id      = azurerm_windows_web_app.example.id

  site_config {}
}

# Output the URLs by constructing them manually
output "production_url" {
  value = "https://${azurerm_windows_web_app.example.name}.azurewebsites.net"
}

output "dev_slot_url" {
  value = "https://${azurerm_windows_web_app.example.name}-dev.azurewebsites.net"
}

output "test_slot_url" {
  value = "https://${azurerm_windows_web_app.example.name}-test.azurewebsites.net"
}

# Promote the dev slot to production
resource "azurerm_web_app_active_slot" "promote_dev_to_prod" {
  slot_id = azurerm_windows_web_app_slot.dev.id

}

output "active_slot_url" {
  value = "https://${azurerm_windows_web_app.example.name}-dev.azurewebsites.net"
}