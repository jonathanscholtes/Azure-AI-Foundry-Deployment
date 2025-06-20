param aiServicesName string
param location string
param identityName string
param customSubdomain string
param vnetId string
param subnetName string


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing= {
  name: identityName
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: aiServicesName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    customSubDomainName: customSubdomain
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: '${vnetId}/subnets/${subnetName}'
          ignoreMissingVnetServiceEndpoint: true
        }
      ]
    }
    
  }
}


resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(managedIdentity.id, aiServices.id, 'cognitive-services-openai-contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a001fd3d-188f-4b5d-821b-7da978bf7442') // Cognitive Services OpenAI Contributor role ID
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
  scope:aiServices
}

resource roleAssignmentML 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(managedIdentity.id, aiServices.id, 'azure-ml-read-or-contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Reader role ID (or change to Contributor if needed)
    principalId: '0736f41a-0425-4b46-bdb5-1563eff02385' // Azure Machine Learning App ID
    principalType: 'ServicePrincipal'
  }
  scope: aiServices
}

output aiservicesID string = aiServices.id
output aiservicesTarget string = aiServices.properties.endpoint
output OpenAIEndPoint string = 'https://${customSubdomain}.openai.azure.com'
output aiServicesName string = aiServices.name
output aiServicesPrincipalId string = aiServices.identity.principalId
