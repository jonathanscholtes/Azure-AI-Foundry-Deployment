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
$timestamp = Get-Date -Format "yyyyMMddHHmmss"


$targetAutoDeletionTime = (Get-Date).ToUniversalTime().AddDays(7).ToString("R")

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
    Write-Host "*****************************************"
    Write-Host "Create VPN Gateway Cert"
    Write-Host "If timeout occurs, rerun the following command from scripts:"
    Write-Host ".\generate_certs.ps1 "
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
        timestamp=$timestamp `
        targetAutoDeletionTime=$targetAutoDeletionTime `
    --query "properties.outputs"


# Parse the deployment output to get app names and resource group
$deploymentOutputJson = $deploymentOutput | ConvertFrom-Json
$resourceGroupName = $deploymentOutputJson.resourceGroupName.value
$functionAppName = $deploymentOutputJson.functionAppName.value

Write-Host "Waiting for App Services before pushing code"

$waitTime = 200  # Total wait time in seconds

# Display counter
for ($i = $waitTime; $i -gt 0; $i--) {
    Write-Host "`rWaiting: $i seconds remaining..." -NoNewline
    Start-Sleep -Seconds 1
}

Write-Host "`rWait time completed!" 

Set-Location -Path .\scripts

# Deploy Function Application
Write-Host "*****************************************"
Write-Host "Deploying Function Application from scripts"
Write-Host "If timeout occurs, rerun the following command from scripts:"
Write-Host ".\deploy_functionapp.ps1 -functionAppName $functionAppName -resourceGroupName $resourceGroupName"
& .\deploy_functionapp.ps1 -functionAppName $functionAppName -resourceGroupName $resourceGroupName


Set-Location -Path ..

Write-Host "Deployment Complete"