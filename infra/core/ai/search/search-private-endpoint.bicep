param aiSearchName string
param location string
param vnetId string
param subnetName string

var privateEndpointName = '${aiSearchName}-pe'
var privateDnsZoneName = 'privatelink.search.windows.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'


resource aiSearch 'Microsoft.Search/searchServices@2021-04-01-preview' existing = {
  name: aiSearchName

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
        name: 'aiServiceConnection'
        properties: {
          privateLinkServiceId: aiSearch.id
          groupIds: [
            'searchService'
          ]
          
        }
      }
    ]
  }
  dependsOn: [
    aiSearch
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
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
