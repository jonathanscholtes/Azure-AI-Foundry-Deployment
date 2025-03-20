@description('Name of the Azure AI Hub workspace')
param aiHubName string

@description('Azure region of the deployment')
param location string

@description('Resource ID of the virtual network')
param vnetId string

@description('Name of the subnet for the private endpoint')
param subnetName string

var privateEndpointName = '${aiHubName}-private-endpoint'
var privateDnsZoneName = 'privatelink.api.azureml.ms'
var privateDnsZoneName2 = 'privatelink.notebooks.azure.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' existing = {
  name: aiHubName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: '${vnetId}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: 'workspace'
        properties: {
          privateLinkServiceId: aiHub.id
          groupIds: ['amlworkspace']
        }
      }
    ]
  }
  dependsOn: [
    aiHub
  ]
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateDnsZone2 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName2
  location: 'global'
  properties: {}
  dependsOn: [
    privateEndpoint
  ]
}

resource privateDnsZoneLink2 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone2
  name: '${privateDnsZoneName2}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: privateDnsZone2.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
