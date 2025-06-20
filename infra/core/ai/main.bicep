param projectName string
param environmentName string
param resourceToken string
param location string
param identityName string
param searchServicename string
param vnetId string
param subnetName string
param applicationInsightsId string
param storageAccountId string
param storageAccountTarget string
param storageAccountName string
param agentSubnetId string
param containerRegistryID string
param storagePrivateEndpointName string

param deployOnlineEndpoints bool = false

@description('Target deletion timestamp in RFC1123 format')
param targetAutoDeletionTime string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string


module search 'search/main.bicep' = { 
  name: 'search'
  params: {
  location:location
  identityName: identityName
  searchServicename: searchServicename
  subnetName: subnetName
  vnetId: vnetId
  }
}

module aifoundry 'aifoundry/main.bicep' = {
  name: 'aifoundry'
  params: { 
    location:location
    environmentName: environmentName
    identityName: identityName
    keyVaultId: keyVaultId
    projectName: projectName
    resourceToken: resourceToken
    subnetName: subnetName
    vnetId: vnetId
    applicationInsightsId:applicationInsightsId
    searchServiceId:search.outputs.searchServiceId
    aiSearchTarget:search.outputs.searchServiceEndpoint
    storageAccountId:storageAccountId
    storageAccountTarget:storageAccountTarget
    storageAccountName:storageAccountName
    containerRegistryID: containerRegistryID
    targetAutoDeletionTime:targetAutoDeletionTime
    agentSubnetId:agentSubnetId
    deployOnlineEndpoints:deployOnlineEndpoints
  }

}

module aiRoleAssignment 'role-assignement.bicep' = {
  name: 'aiRoleAssignment'
  params: { 
    aiHubName:aifoundry.outputs.aiHubName
    aiHubPrincipalId:aifoundry.outputs.aiHubPrincipalId
    searchServiceName: search.outputs.searchServiceName
    searchServicePrincipalId:search.outputs.searchServicePrincipalId
    aiServicesName:aifoundry.outputs.aiServicesName
    aiServicesPrincipalId:aifoundry.outputs.aiServicesPrincipalId
    storageName:storageAccountName
    aiProjectPrincipalId: aifoundry.outputs.aiProjectPrincipalId
    aiServicesPrivateEndpointName: aifoundry.outputs.aiServicesPrivateEndpointName
    searchPrivateEndpointName: search.outputs.searchPrivateEndpointName
    storagePrivateEndpointName:storagePrivateEndpointName
  }
 }

output aiservicesTarget string = aifoundry.outputs.aiservicesTarget
output OpenAIEndPoint string = aifoundry.outputs.OpenAIEndPoint
output searchServiceEndpoint string = search.outputs.searchServiceEndpoint
output searchServiceName string = search.outputs.searchServiceName
