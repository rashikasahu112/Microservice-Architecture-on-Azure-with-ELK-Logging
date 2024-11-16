param project_name string
param env string
var func_names = ['user', 'notes']

// Single shared storage account for both function apps
resource sharedStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: take('sa${project_name}${env}${uniqueString(resourceGroup().id)}', 24)
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Function App Service Plan
resource functionServicePlan 'Microsoft.Web/serverFarms@2023-12-01' = {
  name: 'asp-func-${project_name}-${env}'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = [for func_name in func_names: {
  name: 'func-${func_name}-${project_name}-${env}'
  location: resourceGroup().location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: functionServicePlan.id
    siteConfig: {
      linuxFxVersion: 'Node|20'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${sharedStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${sharedStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${sharedStorageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${sharedStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('func-${func_name}-${project_name}-${env}')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'NODE_ENV'
          value: env
        }
      ]
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}]
