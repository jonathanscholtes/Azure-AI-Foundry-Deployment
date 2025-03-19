param vnetName string
param vnetLocation string
param addressPrefix string = '10.0.0.0/16'

resource routeTable 'Microsoft.Network/routeTables@2023-05-01' = {
  name: 'routeTable-vpn'
  location: vnetLocation
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'route-to-vpn'
        properties: {
          addressPrefix: '0.0.0.0/0'  // Route all traffic through the VPN gateway
          nextHopType: 'VirtualNetworkGateway'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'webSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          routeTable: {
            id: routeTable.id
          }
          delegations: [
            {
              name: 'webDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
                
              }
            }
          ]
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'aiSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          routeTable: {
            id: routeTable.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.CognitiveServices'              
            }
          ]
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'dataSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          routeTable: {
            id: routeTable.id
          }        
           serviceEndpoints: [
            {
              service: 'Microsoft.Storage'              
            }
            {
              service: 'Microsoft.AzureCosmosDB'
            }
          ]
          delegations: [
            {
              name: 'webDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'servicesSubnet'
        properties: {
          addressPrefix: '10.0.4.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          routeTable: {
            id: routeTable.id
          }
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      } 
      {
        name: 'gatewaySubnet'
        properties: {
          addressPrefix: '10.0.5.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }    
    ]
  }
}


output vnetId string = vnet.id

