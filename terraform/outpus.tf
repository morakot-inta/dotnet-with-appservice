output "dotnet_app_url" {
  value = "https://${azurerm_linux_web_app.dotnet.default_hostname}"
  description = "The URL of the .NET 8 App Service"
}

output "application_insights_url" {
  value = "https://portal.azure.com/#resource${azurerm_application_insights.this.id}/overview"
  description = "The URL to the Application Insights resource in Azure Portal"
}