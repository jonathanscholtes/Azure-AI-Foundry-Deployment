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

param storageAccountTarget string

param storageAccountId string

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
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
    '${managedIdentity.id}': {}
    }
  }
  properties: {
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    keyVault: keyVaultId
    applicationInsights:applicationInsightsId
    storageAccount: storageAccountId
    managedNetwork: {
      isolationMode: 'AllowInternetOutbound'
    }
  }
  kind: 'hub'

}

resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-01-01-preview' = {
  parent: aiHub
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

resource aiSearchConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-01-01-preview' = {
  parent: aiHub
  name: '${aiHubName}-connection-AzureAISearch'
  properties: {
    category: 'CognitiveSearch'
    target: '${aiSearchTarget}workspace'
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: '${listAdminKeys(searchServiceId, '2021-04-01-preview').primaryKey}'
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: searchServiceId
    }
  }
}

resource aiStorageConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-01-01-preview' = {
  parent: aiHub
  name: '${aiHubName}-connection-AzureBlob'                         
  properties: {
    category: 'AzureBlob'
    target: storageAccountTarget
    authType: 'AccountKey'
    isSharedToAll: true
    credentials: {
      key: listKeys(storageAccountId, '2021-09-01').keys[0].value  // Primary key
    }
    metadata: {
      ApiType: 'Azure'
      ResourceId: storageAccountId
    }
  }
}

output aiHubID string = aiHub.id
