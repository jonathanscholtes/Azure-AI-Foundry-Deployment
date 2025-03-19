param (
    [string]$Subscription,
    [string]$Location = "eastus2",
    [switch]$DeployVpnGateway
)


# Variables
$projectName = "foundry"
$environmentName = "demo"
$templateFile = "main.bicep"
$deploymentName = "foundrydeploy-$Location"


# Clear account context and configure Azure CLI settings
az account clear
az config set core.enable_broker_on_windows=false
az config set core.login_experience_v2=off

# Login to Azure
az login 
az account set --subscription $Subscription

if ($DeployVpnGateway.IsPresent) {
    Set-Location -Path .\scripts

    # Create Gateway Cert
    Write-Output "*****************************************"
    Write-Output "Create VPN Gateway Cert"
    Write-Output "If timeout occurs, rerun the following command from scripts:"
    Write-Output ".\generate_certs.ps1 "
    $rootCertData = & .\generate_certs.ps1

    Set-Location -Path ..
}

# Start the deployment
$deploymentOutput = az deployment sub create `
    --name $deploymentName `
    --location $Location `
    --template-file $templateFile `
    --parameters `
        environmentName=$environmentName `
        projectName=$projectName `
        location=$Location `
        deployVpnGateway=$($DeployVpnGateway.IsPresent) `
        rootCertData="$rootCertData" `
    --query "properties.outputs"


# Parse the deployment output to get app names and resource group
$deploymentOutputJson = $deploymentOutput | ConvertFrom-Json
$resourceGroupName = $deploymentOutputJson.resourceGroupName.value
$functionAppName = $deploymentOutputJson.functionAppName.value


Start-Sleep -Seconds 300

Set-Location -Path .\scripts


# Deploy Function Application
Write-Output "*****************************************"
Write-Output "Deploying Function Application from scripts"
Write-Output "If timeout occurs, rerun the following command from scripts:"
Write-Output ".\deploy_functionapp.ps1 -functionAppName $functionAppName -resourceGroupName $resourceGroupName"
& .\deploy_functionapp.ps1 -functionAppName $functionAppName -resourceGroupName $resourceGroupName


Set-Location -Path ..

Write-Output "Deployment Complete"