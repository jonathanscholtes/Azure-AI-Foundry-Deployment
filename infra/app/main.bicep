@minLength(1)
@description('Azure region where all resources will be deployed (e.g., "eastus")')
param location string


@description('Token or string used to uniquely identify this resource deployment (e.g., build ID, commit hash)')
param resourceToken string

@description('Name of the User Assigned Managed Identity to assign to deployed services')
param managedIdentityName string

@description('Name of the Log Analytics Workspace for centralized monitoring')
param logAnalyticsWorkspaceName string

@description('Name of the Application Insights instance for telemetry')
param appInsightsName string


@description('Name of the App Service Plan for hosting web apps or APIs')
param appServicePlanName string

@description('Name of the Azure Storage Account used for blob or file storage')
param storageAccountName string

@description('Name of the Azure Key Vault used to store secrets and keys securely')
param keyVaultName string


@description('Name of the Azure AI Search service instance')
param searchServicename string

param OpenAIEndPoint string

param vnetId string

param storageAccountBlobEndPoint string


module appSecurity 'app-secrets.bicep' = {
  name: 'appSecurity'
  params: {
   keyVaultName:keyVaultName
   searchServicename: searchServicename

  }
}

module loaderFunctionWebApp 'loader-function-web-app.bicep' = {
 name: 'loaderFunctionWebApp'
  params: { 
    location: location
    identityName: managedIdentityName
    functionAppName: 'func-loader-${resourceToken}'
    functionAppPlanName: appServicePlanName
    StorageBlobURL: storageAccountBlobEndPoint
    StorageAccountName: storageAccountName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
    keyVaultUri:appSecurity.outputs.keyVaultUri
    OpenAIEndPoint: OpenAIEndPoint
    searchServiceEndpoint: appSecurity.outputs.searchServiceEndpoint
    azureAISearchKey: appSecurity.outputs.AzureAISearchKey
    vnetId: vnetId
    subnetName: 'dataSubnet'
    azureAiSearchBatchSize: 100
    documentChunkOverlap: 500
    documentChunkSize: 2000
}
}
 



output functionAppName string = loaderFunctionWebApp.outputs.functionAppName
