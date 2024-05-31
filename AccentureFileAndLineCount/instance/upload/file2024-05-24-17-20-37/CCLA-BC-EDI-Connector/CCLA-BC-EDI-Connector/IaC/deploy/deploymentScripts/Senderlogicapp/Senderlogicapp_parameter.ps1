param(
$resourcegroup_name,
$inboundlogicappname
)

Install-Module -Name Az.Resources -Scope CurrentUser -Force

################################
## Inbound logic apps details 
################################
Try{
$InboundEndpoint = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value
    if ($InboundEndpoint -ne $null)
    {
      Write-Host "##vso[task.setvariable variable=InboundEndpoint;]$InboundEndpoint"
    }else
        {
        $Endpoint= "InboundEndpoint"
        Write-Host "##vso[task.setvariable variable=InboundEndpoint;]$Endpoint"   
        }
}
catch 
{
    Write-Host $error
}
