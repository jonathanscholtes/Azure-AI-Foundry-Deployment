
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


@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

var aiServicesName  = 'ais-${projectName}-${environmentName}-${resourceToken}'
var aiProjectName  = 'prj-${projectName}-${environmentName}-${resourceToken}'

module aiServices 'azure-ai-services.bicep' = {
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

module aiServicePE 'ai-service-private-endpoint.bicep' = { 
  name: 'aiServicePE'
  params: { 
     aiServicesName:aiServicesName
      location:location
      vnetId:vnetId
      subnetName:'servicesSubnet'
  }
  dependsOn:[aiServices]
}

module aiHub 'ai-hub.bicep' = {
  name: 'aihub'
  params:{
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    aiHubDescription: 'Hub for demo'
    aiServicesId:aiServices.outputs.aiservicesID
    aiServicesTarget: '${aiServices.outputs.OpenAIEndPoint}/'
    keyVaultId: keyVaultId
    location: location
    aiHubFriendlyName: 'AI Demo Hub'
    applicationInsightsId:applicationInsightsId
    identityName:identityName
    aiSearchTarget:aiSearchTarget
    searchServiceId:searchServiceId
  }
}

module aihubPE 'ai-hub-private-endpoint.bicep' = { 
  name: 'aihubPE'
  params: { 
    aiHubName: 'hub-${projectName}-${environmentName}-${resourceToken}'
    location:location
    subnetName:subnetName
    vnetId:vnetId
  }
  dependsOn:[aiHub]
}

module aiProject 'ai-project.bicep' = {
  name: 'aiProject'
  params:{
    aiHubResourceId:aiHub.outputs.aiHubID
    location: location
    aiProjectName: aiProjectName
    aiProjectFriendlyName: 'AI Demo Project'
    aiProjectDescription: 'Project for demo'    
  }
}

module aiModels 'ai-models.bicep' = {
  name:'aiModels'
  params:{
    aiProjectName:aiProjectName
    aiServicesName:aiServicesName
    location: location
    resourceToken:resourceToken
  }
  dependsOn:[aiServices,aiProject]
}


output aiservicesTarget string = aiServices.outputs.aiservicesTarget
output OpenAIEndPoint string = aiServices.outputs.OpenAIEndPoint
