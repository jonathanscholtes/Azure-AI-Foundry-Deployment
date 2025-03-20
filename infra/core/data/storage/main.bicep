param storageAccountName string
param location string
param identityName string
param vnetId string

module storageAccount 'modules/blob-storage-account.bicep' ={
  name: 'storageAccount'
  params:{
     location: location
     storageAccountName:storageAccountName
     vnetId:vnetId
     subnetName:'dataSubnet'
  }
}

module storageContainers 'modules/blob-storage-containers.bicep' = {
  name: 'storageContainers'
  params: {
    storageAccountName: storageAccountName
  }
  dependsOn:[storageAccount]
}

module storageRoles 'modules/blob-storage-roles.bicep' = {
  name: 'storageRoles'
  params:{
    identityName:identityName
     storageAccountName:storageAccountName
  }
  dependsOn:[storageAccount]
}

module storagePe 'modules/blob-storage-pe.bicep' = { 
  name: 'storagePe'
  params: { 
    location:location
    storageAccountName: storageAccountName
    subnetName:'servicesSubnet'
      vnetId: vnetId
  }
  dependsOn:[storageAccount]
}

output storageAccountBlobEndPoint string = storageAccount.outputs.storageAccountBlobEndPoint
output storageAccountId string = storageAccount.outputs.storageAccountId
