@allowed([
  'dev'
  'prod'
])
param env string
var project_name = 'simplenote'

@description('Username for the Virtual Machine.')
param elkVMAdminUsername string = 'elkusername'
@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param elkVMAdminPassword string

module app_service 'app_service.bicep' = {
  name: 'app_service'
  params: {
    env : env
    project_name: project_name
  }
}
module container_registry 'container_registry.bicep' = {
  name: 'container_registry'
  params: {
    env : env
    project_name: project_name
  }
}
module apim 'apim.bicep' = {
  name: 'apim'
  params: {
    env : env
    project_name: project_name
  }
}

module function_apps 'function_apps.bicep' = {
  name: 'function_apps'
  params: {
    env: env
    project_name: project_name
  }
}
module elkvm 'vm.bicep' = {
  name: 'elkvm'
  params: {
    env: env
    project_name: project_name
    adminUsername: elkVMAdminUsername
    adminPasswordOrKey: elkVMAdminPassword
  }
}
module cosmosdb 'cosmos_db.bicep' = {
  name: 'cosmosdb'
  params: {
    env: env
    project_name: project_name
  }
}
