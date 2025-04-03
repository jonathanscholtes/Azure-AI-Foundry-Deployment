param containerRegistryName string
param location string
param vnetId string



module containerregistry 'container-registry.bicep' = {
  name: 'containerregistry'
  params: {
    containerRegistryName: containerRegistryName
    location: location
  }

}

module containerPe 'container-registry-pe.bicep' = {
  name: 'containerPe'
  params: { 
 containerRegistryName:containerRegistryName
  location:location 
   vnetId: vnetId
   subnetName:'servicesSubnet'

  }
dependsOn:[containerregistry]
}

output containerRegistryID string = containerregistry.outputs.containerRegistryID
output containerRegistryName string = containerRegistryName
