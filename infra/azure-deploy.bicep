
@description('Deployment location for resources in this deployment')
param deploymentLocation string // ex: westeurope
param sftpResourceGroupName string
param workspaceName string = 'syn${uniqueString(resourceGroup().id)}'

// Existing SFTP platform resource group
resource sftpResourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  scope: subscription()
  name: sftpResourceGroupName
}

// Existing storage account from SFTP platform
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: sftpResourceGroup
  name: 'gtq7zpxdkwi6ustg'
}

module synapseArtifacts './synapse-artifacts/workspace.bicep' = {
  name: 'synapseArtifactsDeployment'
  params: {
    synapseWorkspaceName: workspaceName
    sftpResourceGroupName: sftpResourceGroupName
    deploymentLocation: deploymentLocation
    storageAccountName: storageAccount.name
  }
  dependsOn: []
}


