@description('AI hub name')
param aiHubName string

@description('AI project name')
param aiProjectName string

@description('Name for Ai Search connection.')
param aiSearchConnectionName string

@description('Name for ACS connection.')
param aoaiConnectionName string

@description('Name for capabilityHost.')
param capabilityHostName string 

@description('Name for customer subnet id')
param customerSubnetId string = ''

var storageConnections = ['${aiProjectName}/workspaceblobstore']
var aiSearchConnection = ['${aiSearchConnectionName}']
var aiServiceConnections = ['${aoaiConnectionName}']

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' existing = {
  name: aiHubName
}

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' existing = {
  name: aiProjectName
}


resource hubCapabilityHost 'Microsoft.MachineLearningServices/workspaces/capabilityHosts@2025-01-01-preview' = {
  name: '${aiHubName}-${capabilityHostName}'
  parent: aiHub
  properties: empty(customerSubnetId) ? {
    capabilityHostKind: 'Agents'
 }: {
   capabilityHostKind: 'Agents'
   customerSubnet: customerSubnetId
 }
 dependsOn:[aiHub]
}

resource projectCapabilityHost 'Microsoft.MachineLearningServices/workspaces/capabilityHosts@2025-01-01-preview' = {
  name: '${aiProjectName}-${capabilityHostName}'
  parent: aiProject
  properties: {
    capabilityHostKind: 'Agents'
    aiServicesConnections: aiServiceConnections
    vectorStoreConnections: aiSearchConnection
    storageConnections: storageConnections
  }
  dependsOn: [
    hubCapabilityHost, aiProject
  ]
}
