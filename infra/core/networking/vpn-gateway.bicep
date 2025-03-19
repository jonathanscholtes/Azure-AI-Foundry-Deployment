param location string
param vnetId string 
param gatewayName string 
param publicIpName string 
param gatewaySubnetName string = 'gatewaySubnet'
param rootCertData string

var tenantId = subscription().tenantId
var audience = '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
var tenant = uri(environment().authentication.loginEndpoint, tenantId)
var issuer = 'https://sts.windows.net/${tenantId}/'



resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    
    publicIPAllocationMethod: 'Static'
  }
}

resource vnetGateway 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {

        name: 'vnetGatewayConfig'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: '${vnetId}/subnets/${gatewaySubnetName}'   
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    customRoutes: {
      addressPrefixes: [
        '10.0.1.0/24' // Web subnet
        '10.0.2.0/24' // AI subnet
        '10.0.3.0/24' // Data subnet
        '10.0.4.0/24' // Services subnet
        '168.63.129.16/32' // Azure DNS for private endpoints  
      ]
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '192.168.100.0/24'
        ]
      }
    
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnAuthenticationTypes: ['Certificate']
      vpnClientRootCertificates: [
        {
          name: 'P2SRootCert'
          properties:{
          publicCertData: rootCertData  // Injecting Base64 certificate data
          }
        }
      ]
      
    }
  }
}
