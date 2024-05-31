Param(
    $logicappname,
    $keyvaultname,
    $resourcegroup_name,
    $subscription_Id
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

#Taking Generate API logic app's Principal ID 
try {
$ID = az resource show --name $logicappname --resource-group $resourcegroup_name --resource-type "Microsoft.Logic/workflows" --query "identity.principalId" | ConvertFrom-Json
}
catch {
    Write-Host $error
}

#Assigning keyvault role for Generate API logic app
try {
az role assignment create --role "Key Vault Secrets User" --assignee-object-id $ID --scope /subscriptions/$subscription_Id/resourcegroups/$resourcegroup_name/providers/Microsoft.KeyVault/vaults/$keyvaultname
}
catch {
    Write-Host $error
}
