param project_name string
param env string
var accountName = 'cosmos-db-${project_name}-${env}'
var databaseName = 'simplenote'
var serverVersion = '6.0'
var defaultConsistencyLevel = 'Session'

@description('Maximum autoscale throughput for the database shared with up to 25 collections')
var sharedAutoscaleMaxThroughput = 1000
@description('Maximum dedicated autoscale throughput for the collection')
var consistencyPolicy = {
  Session: {
    defaultConsistencyLevel: 'Session'
  }
}
var locations = [
  {
    locationName: 'Central India'
    failoverPriority: 0
    isZoneRedundant: false
  }
]

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: accountName
  location: resourceGroup().location
  kind: 'MongoDB'
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    enableFreeTier: true
    apiProperties: {
      serverVersion: serverVersion
    }
    capabilities: [
      {
        name: 'EnableMongo'
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2024-05-15' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      autoscaleSettings: {
        maxThroughput: sharedAutoscaleMaxThroughput
      }
    }
  }
}
