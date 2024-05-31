Param(
    $Functionapp_name,
    $servicebusNamespace,
    $resourcegroup_name,
    $subscription_Id
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

#######Taking Generate API logic app's Principal ID 
try{
$ID = az resource show --name $Functionapp_name --resource-group $resourcegroup_name --resource-type "Microsoft.Web/sites" --query "identity.principalId" | ConvertFrom-Json
}
catch 
{
    Write-Host $error
}

########Assigning Azure Service Bus Data Receiver for Function app

$servicebus = az resource show --name $servicebusNamespace --resource-group $resourcegroup_name --resource-type "Microsoft.ServiceBus/namespaces"
If($servicebus -ne $null)
{
try {
az role assignment create --role "Azure Service Bus Data Receiver" --assignee-object-id $ID --scope /subscriptions/$subscription_Id/resourcegroups/$resourcegroup_name/providers/Microsoft.ServiceBus/namespaces/$servicebusNamespace
}
catch {
    Write-Host $error
}
}
else
{
    Write-Host "Service bus is not created yet"
}
