metadata description = 'Creates an Application Insights instance and a Log Analytics workspace.'
param logAnalyticsName string
param applicationInsightsName string
param location string = resourceGroup().location

module logAnalytics 'loganalytics.bicep' = {
  name: 'loganalytics'
  params: {
    name: logAnalyticsName
    location: location
  }
}

module applicationInsights 'applicationinsights.bicep' = {
  name: 'applicationinsights'
  params: {
    name: applicationInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

output applicationInsightsConnectionString string = applicationInsights.outputs.connectionString
output applicationInsightsId string = applicationInsights.outputs.id
output applicationInsightsInstrumentationKey string = applicationInsights.outputs.instrumentationKey
output applicationInsightsName string = applicationInsights.outputs.name
output logAnalyticsWorkspaceId string = logAnalytics.outputs.id
output logAnalyticsWorkspaceName string = logAnalytics.outputs.name
