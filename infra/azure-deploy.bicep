
@description('Deployment location for resources in this deployment')
param deploymentLocation string // ex: westeurope
param workspaceName string = 'syn${uniqueString(resourceGroup().id)}'

module synapseArtifacts './synapse-artifacts/workspace.bicep' = {
  name: 'synapseArtifactsDeployment'
  params: {
    synapseWorkspaceName: workspaceName
    deploymentLocation: deploymentLocation
  }
}


