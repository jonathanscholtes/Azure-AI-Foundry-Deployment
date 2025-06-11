param vnetName string
param vnetLocation string
param dnsResolverName string


resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
        '192.168.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.6.4'
      ]
    }
    subnets: [
      {
        name: 'webSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
       
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
    
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      } 
      {
        name: 'gatewaySubnet'
        properties: {
          addressPrefix: '10.0.5.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }  
      {
        name: 'dnsResolverSubnet'  // New subnet for DNS Private Resolver
        properties: {
          addressPrefix: '10.0.6.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
         type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'agentSubnet'
        properties: {
          addressPrefix: '192.168.7.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
      
          delegations: [
            {
              name: 'Microsoft.app/environments'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }

    ]
  }
}


// DNS Private Resolver
resource dnsResolver 'Microsoft.Network/dnsResolvers@2023-07-01-preview' = {
  name: dnsResolverName
  location: vnetLocation
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Inbound Endpoint
resource inboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2023-07-01-preview' = {
  parent: dnsResolver
  name: 'inboundEndpoint'
  location: vnetLocation
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Static'
        privateIpAddress: '10.0.6.4' 
        subnet: {
          id: '${vnet.id}/subnets/dnsResolverSubnet'
        }
      }
    ]
  }
}






output vnetId string = vnet.id
output agentSubnetId string = '${vnet.id}/subnets/agentSubnet' //resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'agentSubnet')

