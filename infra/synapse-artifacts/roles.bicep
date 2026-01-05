
param storageAccountName string
param synapsePrincipalId string

// Existing storage account from SFTP platform
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Optional: Grant Synapse workspace managed identity Storage Blob Data Contributor on ADLS
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: 'roleAssignment${uniqueString(storageAccount.id, synapsePrincipalId)}'
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: synapsePrincipalId
    principalType: 'ServicePrincipal'
  }
}
