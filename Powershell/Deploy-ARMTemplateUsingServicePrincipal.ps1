Param
(
[Parameter(Mandatory=$True)] $password,
[Parameter(Mandatory=$True)] $username,
[Parameter(Mandatory=$True)] $tenantId,
[Parameter(Mandatory=$True)] $subscriptionId,
[Parameter(Mandatory=$True)] $resourceGroup,
[Parameter(Mandatory=$True)] $templateFilePath,
[Parameter(Mandatory=$True)] $paramsFilePath
)

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

Connect-AzAccount -Credential $credential -Tenant $tenantId -SubscriptionId $subscriptionId -ServicePrincipal 
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $templateFilePath -TemplateParameterFile $paramsFilePath