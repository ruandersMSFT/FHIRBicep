param apiManagementServiceName string
param createApiManagement bool
param location string
param sku string
param skuCount int
param publisherName string
param publisherEmail string
param appInsightsInstrumentationKey string

resource apim 'Microsoft.ApiManagement/service@2021-12-01-preview' = if (createApiManagement)  {
  name: apiManagementServiceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }

  resource apimLogger 'loggers' = {
    name: 'appinsights'
    properties: {
      loggerType: 'applicationInsights'
      credentials: {
        appInsightsInstrumentationKey: appInsightsInstrumentationKey
        instrumentationKey: appInsightsInstrumentationKey
      }
      isBuffered: true
    }
  }
  
  resource apimDiagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      alwaysLog: 'allErrors'
      httpCorrelationProtocol: 'W3C'
      logClientIp: true
      loggerId: apimLogger.id
      sampling: {
        samplingType: 'fixed'
        percentage: 100
      }
      frontend: {
        request: {
          dataMasking: {
            queryParams: [
              {
                value: '*'
                mode: 'Hide'
              }
            ]
          }
        }
      }
      backend: {
        request: {
          dataMasking: {
            queryParams: [
              {
                value: '*'
                mode: 'Hide'
              }
            ]
          }
        }
      }
    }
  }

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apimExisting 'Microsoft.ApiManagement/service@2021-12-01-preview' existing = if (!createApiManagement) {
  name: apiManagementServiceName
}
var newOrExistingApiManagementName = createApiManagement ? apim.name : apimExisting.name
  

output name string = newOrExistingApiManagementName
output serviceLoggerId string = apim::apimLogger.id
