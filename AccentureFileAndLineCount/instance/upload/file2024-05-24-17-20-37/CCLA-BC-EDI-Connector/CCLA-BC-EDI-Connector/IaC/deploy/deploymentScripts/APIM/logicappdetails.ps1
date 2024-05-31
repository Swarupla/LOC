param(
$resourcegroup_name,
$inboundlogicappname,
$Acklogicappname
)

Install-Module -Name Az.Resources -Scope CurrentUser -Force

################################
## Inbound logic app details 
################################
Try{
$String1 = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value.Substring(0,(Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value.IndexOf("sig"))
$length = $String1.Length+4

$String2 = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value

$Total_length = $String2.Length 

$a= $Total_length - $length

$Logicapp_access_key_value= $String2.Substring($length,$a)

$serviceUrl_accessEndpoint = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value.Substring(0,(Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $inboundlogicappname -TriggerName manual).Value.IndexOf("manual"))

Write-Host "##vso[task.setvariable variable=serviceUrl_accessEndpoint;]$serviceUrl_accessEndpoint"
Write-Host "##vso[task.setvariable variable=Logicapp_access_key_value;]$Logicapp_access_key_value"

}
Catch 
{
   Write-Host $error
}
################################
## Ack logic app details 
################################
try {

$String3 = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Acklogicappname -TriggerName manual).Value.Substring(0,(Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Acklogicappname -TriggerName manual).Value.IndexOf("sig"))
$length1 = $String3.Length+4

$String4 = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Acklogicappname -TriggerName manual).Value

$Total_length1 = $String4.Length 

$b= $Total_length1 - $length1

$ack_Logicapp_access_key_value= $String4.Substring($length1,$b)

$ack_serviceUrl_accessEndpoint = (Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Acklogicappname -TriggerName manual).Value.Substring(0,(Get-AzLogicAppTriggerCallbackUrl -ResourceGroupName $resourcegroup_name -Name $Acklogicappname -TriggerName manual).Value.IndexOf("manual"))

Write-Host "##vso[task.setvariable variable=ack_serviceUrl_accessEndpoint;]$ack_serviceUrl_accessEndpoint"
Write-Host "##vso[task.setvariable variable=ack_Logicapp_access_key_value;]$ack_Logicapp_access_key_value"

}
catch 
{
   Write-Host $error
}

