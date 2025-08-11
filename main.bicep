param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-analytics-workspace-${uniqueString(resourceGroup().id)}'
  location: location
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'application-insights-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource funcApp1Storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: take('${'stfuncapp1'}${replace(uniqueString(resourceGroup().id), '-', '')}', 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource hostingPlan1 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'hosting-plan-1-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
} 
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }
}

resource funcApp1 'Microsoft.Web/sites@2023-12-01' = {
	name: 'func-app-1-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: hostingPlan1.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcApp1Storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcApp1Storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcApp1Storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcApp1Storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(funcApp1Storage.name)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource funcApp2Storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: take('${'stfuncapp2'}${replace(uniqueString(resourceGroup().id), '-', '')}', 24)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource hostingPlan2 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'hosting-plan-2-${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
} 
  kind: 'functionapp,linux'
  properties: {
    reserved: true
  }
}
    
resource funcApp2 'Microsoft.Web/sites@2023-12-01' = {
	name: 'func-app-2-${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'functionapp,linux'
  properties: {
    reserved: true
    serverFarmId: hostingPlan2.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcApp2Storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcApp2Storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcApp2Storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcApp2Storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(funcApp2Storage.name)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}
