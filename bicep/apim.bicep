param project_name string
param env string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: 'apim-${project_name}-${env}'
  location: resourceGroup().location
  sku: {
    name: 'Consumption'
    capacity: 0
  }
  properties: {
    publisherEmail: 'rashikasahu@nagarro.com'
    publisherName: 'Rashika Sahu'
  }
}

