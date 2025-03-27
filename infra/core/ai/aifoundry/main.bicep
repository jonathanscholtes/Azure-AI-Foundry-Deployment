
param projectName string
param environmentName string
param resourceToken string
param location string
param identityName string
param vnetId string
param subnetName string
param applicationInsightsId string
param aiSearchTarget string
param searchServiceId string
param storageAccountId string
param storageAccountTarget string
param storageAccountName string



@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

var aiServicesName  = 'ais-${projectName}-${environmentName}-${resourceToken}'
var aiProjectName  = 'prj-${projectName}-${environmentName}-${resourceToken}'

module aiServices 'modules/azure-ai-services.bicep' = {
  name: 'aiServices'
  params: {
    aiServicesName: aiServicesName
    location: location
    identityName: identityName
    customSubdomain: 'openai-app-${resourceToken}'
    vnetId:vnetId
    subnetName:subnetName
  }
}

module aiServicePE 'modules/ai-service-private-endpoint.bicep' = { 
  name: 'aiServicePE'
  params: { 
     aiServicesName:aiServicesName
      location:location
      vnetId:vnetId
      subnetName:'servicesSubnet'
  }
  dependsOn:[aiServices]
}

module aiHub 'modules/ai-hub.bicep' = {
  name: 'aihub'
  params:{
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    aiHubDescription: 'Hub for demo'
    aiServicesResourceId:aiServices.outputs.aiservicesID
    aiServicesEndpoint: '${aiServices.outputs.OpenAIEndPoint}/'
    keyVaultResourceId: keyVaultId
    location: location
    aiHubFriendlyName: 'AI Demo Hub'
    appInsightsResourceId:applicationInsightsId
    managedIdentityName:identityName
    aiSearchEndpoint:aiSearchTarget
    aiSearchResourceId:searchServiceId
    storageAccountResourceId:storageAccountId
    blobStorageEndpoint:storageAccountTarget
    storageAccountName:storageAccountName
    blobContainerName:'workspace'
  }
}

module aihubPE 'modules/ai-hub-private-endpoint.bicep' = { 
  name: 'aihubPE'
  params: { 
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    location:location
    subnetName:'servicesSubnet'
    vnetId:vnetId
  }
  dependsOn:[aiHub]
}

module aiProject 'modules/ai-project.bicep' = {
  name: 'aiProject'
  params:{
    aiHubResourceId:aiHub.outputs.aiHubResourceId
    location: location
    aiProjectName: aiProjectName
    aiProjectFriendlyName: 'AI Demo Project'
    aiProjectDescription: 'Project for demo'    
  }
}

module aiModels 'modules/ai-models.bicep' = {
  name:'aiModels'
  params:{
    aiProjectName:aiProjectName
    aiServicesName:aiServicesName
    location: location
    resourceToken:resourceToken
  }
  dependsOn:[aiServices,aiProject]
}

module aiOnlineEndpoints 'modules/ai-online-endpoint.bicep' = {
  name: 'aiOnlineEndpoints'
  params: { 
    aiProjectName:aiProjectName
    location:location
    managedIdentityName:identityName
    onlineEndpointName: 'src-${projectName}-${environmentName}-${resourceToken}'
  }
  dependsOn:[aiProject]
}


output aiservicesTarget string = aiServices.outputs.aiservicesTarget
output OpenAIEndPoint string = aiServices.outputs.OpenAIEndPoint
