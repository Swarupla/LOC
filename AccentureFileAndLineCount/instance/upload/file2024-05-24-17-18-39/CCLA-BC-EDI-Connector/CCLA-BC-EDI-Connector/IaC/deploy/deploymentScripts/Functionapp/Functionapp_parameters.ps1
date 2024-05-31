param(
$servicebusNamespace,
$servicebus_accesspolicy,
$resourcegroup_name,
$cosmosDB_Name,
$Outboundlogicappname
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

########Taking Servicebus Details 
try {
$servicebus = Get-AzServiceBusKey -ResourceGroup $resourcegroup_name -Namespace $ServicebusNamespace -Name $servicebus_accesspolicy
$SERVICEBUS_CS = $servicebus.PrimaryConnectionString

Write-Host "##vso[task.setvariable variable=SERVICEBUS_CS;]$SERVICEBUS_CS"
}
catch
{
    Write-Host $error 
}

#########Taking cosmosDB Details 

try {
$cosmos = Get-AzCosmosDBAccount -ResourceGroupName $resourcegroup_name -Name $cosmosDB_Name
$COSMOS_ACCOUNT_HOST = $cosmos.DocumentEndpoint
$Key = Get-AzCosmosDBAccountKey -ResourceGroupName $resourcegroup_name -Name $cosmosDB_Name -Type "Keys"
$COSMOS_ACCOUNT_KEY =$Key.PrimaryMasterKey

Write-Host "##vso[task.setvariable variable=COSMOS_ACCOUNT_HOST;]$COSMOS_ACCOUNT_HOST"
Write-Host "##vso[task.setvariable variable=COSMOS_ACCOUNT_KEY;]$COSMOS_ACCOUNT_KEY"
}
catch
{
    Write-Host $error 
}

############Taking outbound logicapp trigger

try {
$ACTIVITY_APP_ENDPOINT_OUTBOUND = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Outboundlogicappname -TriggerName manual).Value
Write-Host "##vso[task.setvariable variable=ACTIVITY_APP_ENDPOINT_OUTBOUND;]$ACTIVITY_APP_ENDPOINT_OUTBOUND"
}
catch
{
   Write-Host $error 
}