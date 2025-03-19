@description('Azure region of the deployment')
param location string

@description('AI hub name')
param aiHubName string

param aiHubFriendlyName string

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the AI Services resource')
param aiServicesId string

@description('Resource ID of the AI Services endpoint')
param aiServicesTarget string

param aiSearchTarget string

param applicationInsightsId string

param identityName string

param searchServiceId string


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing= {
  name: identityName
}

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiHubName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    keyVault: keyVaultId
    applicationInsights:applicationInsightsId
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
    }
  }
  kind: 'hub'

  resource aiServicesConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AzureOpenAI'
    properties: {
      category: 'AzureOpenAI'
      target: aiServicesTarget
      authType: 'ApiKey'
      isSharedToAll: true
      credentials: {
        key: '${listKeys(aiServicesId, '2021-10-01').key1}'
      }
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }

  resource aiSearchConnection 'connections@2024-01-01-preview' = {
    name: '${aiHubName}-connection-AzureAISearch'
    properties: {
      category: 'AzureAISearch'
      target: aiSearchTarget
      authType: 'ManagedIdentity'
      isSharedToAll: true
      credentials: {
        clientId: managedIdentity.id  
      }
      metadata: {
        ResourceId: searchServiceId
      }
    }
  }

}

output aiHubID string = aiHub.id
