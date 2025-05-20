locals {
  project = "andromedra"
  location = "Southeastasia"
  subscription_id = "ab67c280-e37d-49b2-9a0d-f575ed98d7be" 
}

resource "random_string" "this" {
  length  = 4
  special = false 
  upper   = false
  numeric = false 
}


resource "azurerm_resource_group" "this" {
  name     = "${local.project}-rg" 
  location = local.location 
}

resource "azurerm_service_plan" "this" {
  name                = "${local.project}-plan"
  resource_group_name = azurerm_resource_group.this.name 
  location            = azurerm_resource_group.this.location 
  os_type             = "Linux"
  sku_name            = "B2"
}

# .NET 9 App Service
resource "azurerm_linux_web_app" "dotnet" {
  name                = "${local.project}-dotnet-${random_string.this.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id
  
  # App settings for the .NET 9 app
  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }
  
  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on                = true
    ftps_state               = "Disabled"
    minimum_tls_version      = "1.2"
    health_check_path        = "/health"
    health_check_eviction_time_in_min = 2
  }
  
  # Enable logging
  logs {
    http_logs {
      file_system {
        retention_in_mb   = 35
        retention_in_days = 30
      }
    }
    application_logs {
      file_system_level = "Information"
    }
  }
  
  tags = {
    environment = "production"
    project     = local.project
    runtime     = "dotnet9"
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name               = "${local.project}-${random_string.this.result}-law"
  location            = azurerm_resource_group.this.location 
  resource_group_name = azurerm_resource_group.this.name 
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    environment = "production"
    project     = local.project
  }
}

resource "azurerm_application_insights" "this" {
  name                = "${local.project}-${random_string.this.result}-ai"
  location            = azurerm_resource_group.this.location 
  resource_group_name = azurerm_resource_group.this.name 
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  
  tags = {
    environment = "production"
    project     = local.project
  }
}