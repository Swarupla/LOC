param(
$Senderlogicappname,
$Outboundlogicappname,
$Acklogicappname,
$Functionapp_name,
$resourcegroup_name,
$cosmosDB_Name,
$CosmosDB_scope,
$roledefinitionid
)

Install-Module -Name Az.Resources -Scope CurrentUser -Force

#Taking Logic app's Principal IDs##
try {
$Outboundlogicapp_PrincipalID = az resource show --name $Outboundlogicappname --resource-group $resourcegroup_name --resource-type "Microsoft.Logic/workflows" --query "identity.principalId" | ConvertFrom-Json
$Senderlogicapp_PrincipalID = az resource show --name $Senderlogicappname --resource-group $resourcegroup_name --resource-type "Microsoft.Logic/workflows" --query "identity.principalId" | ConvertFrom-Json
$Acklogicapp_PrincipalID = az resource show --name $Acklogicappname --resource-group $resourcegroup_name --resource-type "Microsoft.Logic/workflows" --query "identity.principalId" | ConvertFrom-Json
$Functionapp_PrincipalID = az resource show --name $Functionapp_name --resource-group $resourcegroup_name --resource-type "Microsoft.Web/sites" --query "identity.principalId" | ConvertFrom-Json

# CosmosDB SQL Role Assignment Task##

$cosmosDB = $cosmosDB_Name.ToLower()

az cosmosdb sql role assignment create --account-name $cosmosDB --resource-group $resourcegroup_name --scope $CosmosDB_scope --principal-id $Outboundlogicapp_PrincipalID --role-definition-id $roledefinitionid
az cosmosdb sql role assignment create --account-name $cosmosDB --resource-group $resourcegroup_name --scope $CosmosDB_scope --principal-id $Senderlogicapp_PrincipalID --role-definition-id $roledefinitionid
az cosmosdb sql role assignment create --account-name $cosmosDB --resource-group $resourcegroup_name --scope $CosmosDB_scope --principal-id $Acklogicapp_PrincipalID --role-definition-id $roledefinitionid
az cosmosdb sql role assignment create --account-name $cosmosDB --resource-group $resourcegroup_name --scope $CosmosDB_scope --principal-id $Functionapp_PrincipalID --role-definition-id $roledefinitionid
}
catch 
{
    Write-Host $error
}