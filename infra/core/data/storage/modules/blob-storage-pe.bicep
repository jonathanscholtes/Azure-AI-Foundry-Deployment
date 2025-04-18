param storageAccountName string
param location string
param vnetId string
param subnetName string

var privateDnsZoneName = 'privatelink.blob.core.windows.net'
var privateEndpointName = '${storageAccountName}-pe'
var pvtEndpointDnsGroupName = '${privateEndpointName}/default'


var privateFileDnsZoneName = 'privatelink.file.core.windows.net'
var privateEndpointFileName = '${storageAccountName}-file-pe'
var pvtEndpointFileDnsGroupName = '${privateEndpointFileName}/default'


resource storageAcct 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName

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
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageAcct.id
          groupIds: [
            'blob'
          ]
        }
        
      }
      
    ]
  }
  dependsOn: [
    storageAcct
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

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
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


resource privateEndpointFile 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointFileName
  location: location
  properties: {
    subnet: {
      id: '${vnetId}/subnets/${subnetName}'
    }

    privateLinkServiceConnections: [
      {
        name: privateEndpointFileName
        properties: {
          privateLinkServiceId: storageAcct.id
          groupIds: [
            'file'
          ]
        }
        
      }
      
    ]
  }
  dependsOn: [
    storageAcct
  ]
}


resource privateFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateFileDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    privateEndpointFile
  ]
}

resource privateFileDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateFileDnsZone
  name: '${privateFileDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource pvtFileEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: pvtEndpointFileDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateFileDnsZone.id
          
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointFile
  ]
}
