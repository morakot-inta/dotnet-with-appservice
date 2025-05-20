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

resource "azurerm_mssql_server" "this" {
  name                         = "${local.project}-sql-${random_string.this.result}"
  resource_group_name          = azurerm_resource_group.this.name 
  location                     = azurerm_resource_group.this.location 
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
  
  tags = {
    environment = "production"
    project     = local.project
  }
}

# MSSQL Database for testing (low spec)
resource "azurerm_mssql_database" "test" {
  name                        = "${local.project}-testdb"
  server_id                   = azurerm_mssql_server.this.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 2
  read_scale                  = false
  sku_name                    = "Basic"
  zone_redundant              = false
  
  tags = {
    environment = "test"
    project     = local.project
    purpose     = "testing"
  }
}

# Allow Azure services to access the SQL server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id           = azurerm_mssql_server.this.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}