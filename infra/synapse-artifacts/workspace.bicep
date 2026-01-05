
param synapseWorkspaceName string
param deploymentLocation string
param sftpResourceGroupName string
param storageAccountName string

@description('SQL administrator login for Synapse workspace')
param sqlAdminLogin string = 'synadmin'
@description('SQL administrator password for Synapse workspace')
@secure()
param sqlAdminPassword string = 'Test-StrongP@ssw0rd123!'

// Existing SFTP platform resource group
resource sftpResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  scope: subscription()
  name: sftpResourceGroupName
}

// Existing storage account from SFTP platform
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: sftpResourceGroup
  name: storageAccountName
}

// Create filesystem (container) in ADLS
resource fileSystem 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/synapseadlsfilesystem'
  dependsOn: [storageAccount]
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
      accountUrl: storageAccount.properties.primaryEndpoints.dfs
      filesystem: fileSystem.name
      createManagedPrivateEndpoint: true  // Optional: for secure access
    }
    sqlAdministratorLogin: sqlAdminLogin
    sqlAdministratorLoginPassword: sqlAdminPassword
    azureADOnlyAuthentication: false  // Set to true for AAD-only
  }
}

// Deploy role assignment via module at different RG scope
module storageRoleAssign 'roles.bicep' = {
  name: 'synapse-storage-role'
  scope: resourceGroup()
  params: {
    storageAccountName: storageAccount.name
    synapsePrincipalId: synapseWorkspace.identity.principalId
  }
}


