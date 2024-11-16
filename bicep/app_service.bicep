param project_name string
param env string

resource appServicePlan 'Microsoft.Web/serverFarms@2023-12-01' = {
  name: 'asp-${project_name}-${env}'
  location: resourceGroup().location
  sku: {
    name: 'B1' 
  }
  kind: 'linux'
  properties: {
    reserved: true 
  }
}

resource appServiceApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'app-${project_name}-${env}'
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
      ]
      linuxFxVersion: 'DOCKER|nginx:latest'
      alwaysOn: true
    }
  }
}
