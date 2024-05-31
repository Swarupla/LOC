param(
$resourcegroup_name,
$Apimname
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

#Taking APIM Ip address for Whitelisting 
try {
$APIM = Get-AzApiManagement -ResourceGroupName $resourcegroup_name -Name $Apimname
$APIM_IPaddress = $APIM.PublicIPAddresses

Write-Host "##vso[task.setvariable variable=APIM_IPaddress;]$APIM_IPaddress"
}
catch {
    Write-Host $error
}

