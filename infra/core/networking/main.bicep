param vnetName string
param location string
param gatewayName string
param publicIpName string
param rootCertData string
param deployVpnGateway bool = false


module vNet 'vnet.bicep' = { 
  name: 'vNet'
  params: { 
     vnetLocation:location
     vnetName:vnetName
  }
}

module vpnGateway 'vpn-gateway.bicep' = if (deployVpnGateway) { 
  name: 'vpnGateway'
  params: {
    location:location
    vnetId: vNet.outputs.vnetId
    publicIpName: publicIpName
    gatewayName: gatewayName
    rootCertData:rootCertData

  }
}

output vnetId string = vNet.outputs.vnetId
