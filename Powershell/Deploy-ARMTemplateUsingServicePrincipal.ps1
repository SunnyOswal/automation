Param
(
[Parameter(Mandatory=$True)] $password,
[Parameter(Mandatory=$True)] $username,
[Parameter(Mandatory=$True)] $tenantId,
[Parameter(Mandatory=$True)] $subscriptionId,
[Parameter(Mandatory=$True)] $resourceGroup,
[Parameter(Mandatory=$True)] $region,
[Parameter(Mandatory=$True)] $templateFilePath,
[Parameter(Mandatory=$True)] $paramsFilePath
)
Write-Host "---------------------------------------"
Get-Content $templateFilePath
Write-Host "---------------------------------------"
Get-Content $paramsFilePath
Write-Host "---------------------------------------"

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

Connect-AzAccount -Credential $credential -Tenant $tenantId -SubscriptionId $subscriptionId -ServicePrincipal
New-AzResourceGroup -Name $resourceGroup -Location $region -Force
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $templateFilePath -TemplateParameterFile $paramsFilePath
