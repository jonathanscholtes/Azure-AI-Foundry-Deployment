metadata description = 'Creates an Application Insights instance based on an existing Log Analytics workspace.'
param name string
param location string = resourceGroup().location
param tags object = {}
param logAnalyticsWorkspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}


output connectionString string = replace(applicationInsights.properties.ConnectionString,applicationInsights.properties.InstrumentationKey,'00000000-0000-0000-0000-000000000000')
output id string = applicationInsights.id
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output name string = applicationInsights.name
