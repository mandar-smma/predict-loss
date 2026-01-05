
param synapseWorkspaceName string
param deploymentLocation string

@description('SQL administrator login for Synapse workspace')
param sqlAdminLogin string = 'synadmin'
@description('SQL administrator password for Synapse workspace')
@secure()
param sqlAdminPassword string = 'Test-StrongP@ssw0rd123!'

// Create ADLS Gen2 account (required for default storage)
resource synapseStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'adls${uniqueString(resourceGroup().id)}'
  location: deploymentLocation
  tags: { RESSOURCE_PURPOSE: 'Storage' }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  parent: synapseStorageAccount
  name: 'default'
}

resource containerService 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  parent: blobService
  name: 'default'
}

// Deploy Synapse Workspace (serverless included automatically)
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: deploymentLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: synapseStorageAccount.properties.primaryEndpoints.dfs
      filesystem: containerService.name
      createManagedPrivateEndpoint: true  // Optional: for secure access
    }
    sqlAdministratorLogin: sqlAdminLogin
    sqlAdministratorLoginPassword: sqlAdminPassword
    azureADOnlyAuthentication: false  // Set to true for AAD-only
  }
}

// Deploy role assignment via module at different RG scope
module storageRoleAssign 'roles.bicep' = {
  name: 'synapsestorage-rolemodule'
  scope: resourceGroup()
  params: {
    storageAccountName: synapseStorageAccount.name
    synapsePrincipalId: synapseWorkspace.identity.principalId
  }
}


