
@description('Name of the AI project')
param aiProjectName string

@description('Azure region of the deployment')
param location string

@description('Name of the user-assigned managed identity')
param managedIdentityName string

param onlineEndpointName string

// Existing Managed Identity Reference
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}



resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' existing = {
  name: aiProjectName
}


// Online Endpoint Definition
resource onlineEndpoint 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2025-01-01-preview' = {
  parent: aiProject 
  name: onlineEndpointName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}  
    }
  }
  properties: {
    authMode: 'Key'
    publicNetworkAccess: 'Disabled'
  }
}

// Model Deployment Definition
resource modelDeployment 'Microsoft.MachineLearningServices/workspaces/onlineEndpoints/deployments@2025-01-01-preview' = {
  parent: onlineEndpoint  
  name: 'roberta-base'
  location: location
  properties: {
    model:'azureml://registries/HuggingFace/models/roberta-base/versions/24'  
    instanceType: 'Standard_DS3_v2'
    endpointComputeType: 'Managed'
    scaleSettings: {
      scaleType: 'Default'
    }
  }
  sku: {
    name: 'Default'
    tier: 'Standard'
    capacity: 1
}
}

