param(
$resourcegroup_name,
$keyvaultname,
$location
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

## Creating Basic Keyvault if not available
try{
New-AzKeyVault -Name $keyvaultname -ResourceGroupName $resourcegroup_name -Location $location -Sku premium
}
catch {
    Write-Host $error
}