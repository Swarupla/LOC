Param(
    $Generate_API_logicappname,
    $resourcegroup_name
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

##Taking Generate API logic app's Principal ID
try{
$objectId = az resource show --name $Generate_API_logicappname --resource-group $resourcegroup_name --resource-type "Microsoft.Logic/workflows" --query "identity.principalId" | ConvertFrom-Json
Write-Host "##vso[task.setvariable variable=objectId;]$objectId"
}
catch 
{
    Write-Host $error
}