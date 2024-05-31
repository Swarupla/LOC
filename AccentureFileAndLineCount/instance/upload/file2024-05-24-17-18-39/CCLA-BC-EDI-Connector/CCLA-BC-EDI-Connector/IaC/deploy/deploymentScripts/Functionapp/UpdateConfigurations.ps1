param
(
$servicebusQueuename
)

## Updating the Service bus queue name app config ##

$function = Get-content -Path .\src\main\listener\function-app\OutboundListener\function.json
$function | Foreach-object { $_ -replace "<<servicebusQueuename>>",$servicebusQueuename } |
Set-content -path .\src\main\listener\function-app\OutboundListener\function.json -force



