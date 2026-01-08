
@description('Deployment location for resources in this deployment')
param deploymentLocation string = 'westeurope'
param workspaceName string = 'syn${uniqueString(resourceGroup().id)}'
param sqlAdminPassword string

module synapseArtifacts './synapse-artifacts/workspace.bicep' = {
  name: 'synapseArtifactsDeployment'
  params: {
    synapseWorkspaceName: workspaceName
    deploymentLocation: deploymentLocation
    sqlAdminPassword: sqlAdminPassword
  }
}


