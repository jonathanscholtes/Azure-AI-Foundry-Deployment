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
  }

}



output aiservicesTarget string = aifoundry.outputs.aiservicesTarget
output OpenAIEndPoint string = aifoundry.outputs.OpenAIEndPoint
output searchServiceEndpoint string = search.outputs.searchServiceEndpoint
