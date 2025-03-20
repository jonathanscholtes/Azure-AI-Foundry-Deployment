@description('Name of the AI project')
param aiProjectName string

@description('Azure region of the deployment')
param location string

@description('Name of the Azure AI Services instance')
param aiServicesName string

@description('Unique resource token for endpoint naming')
param resourceToken string

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' existing = {
  name: aiProjectName
}

resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
}

resource phi4Endpoint 'Microsoft.MachineLearningServices/workspaces/serverlessEndpoints@2024-07-01-preview' = {
  parent: aiProject
  location: location
  name: 'phi-4-${resourceToken}'
  properties: {
    authMode: 'Key'
    contentSafety: {
      contentSafetyStatus: 'Enabled'
    }
    modelSettings: {
      modelId: 'azureml://registries/azureml/models/Phi-4'
    }
  }
  sku: {
    name: 'Consumption'
    tier: 'Free'
  }
}

resource o1Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiServices
  name: 'o1-mini'
  sku: {
    capacity: 10
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'o1-mini'
      version: '2024-09-12'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
}

resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    capacity: 80
    name: 'GlobalStandard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  dependsOn: [o1Deployment]
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiServices
  name: 'text-embedding'
  sku: {
    capacity: 120
    name: 'Standard'
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  dependsOn: [gpt4oDeployment]
}
