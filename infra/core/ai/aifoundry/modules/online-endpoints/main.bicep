
@description('Name of the AI project')
param aiProjectName string

param environmentName string
param resourceToken string
param location string
param identityName string



module phiOnlineEndpoint 'phi-online-endpoint.bicep' = {
  name: 'phiOnlineEndpoint'
  params: { 
    aiProjectName: aiProjectName
    location:location
    managedIdentityName: identityName
    onlineEndpointName:'phi-${environmentName}-${resourceToken}'
  }

}

module robertaOnlineEndpoint 'roberta-online-endpoint.bicep' = {
  name: 'robertaOnlineEndpoint'
  params: { 
    aiProjectName: aiProjectName
    location:location
    managedIdentityName: identityName
    onlineEndpointName:'roberta-${environmentName}-${resourceToken}'
  }

}



