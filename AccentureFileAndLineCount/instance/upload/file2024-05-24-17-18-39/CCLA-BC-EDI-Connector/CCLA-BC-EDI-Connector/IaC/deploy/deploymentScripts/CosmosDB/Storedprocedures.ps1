param(
  [Parameter(Mandatory=$true,HelpMessage="cosmosDB_Name")]
  [string]$cosmosDB_Name,

  [Parameter(Mandatory=$true,HelpMessage="CosmosDatabaseName")]
  [string]$CosmosDatabaseName,

  [Parameter(Mandatory=$true,HelpMessage="resourcegroup_name")]
  [string]$resourcegroup_name,
 
  [Parameter(Mandatory=$true,HelpMessage="Containernames")]
  [string[]]$Containers,

  [Parameter(Mandatory=$true,HelpMessage="BuildId")]
  [int]$buildId
)
## COSMOS DB stored procedures Create/ Update ###

write-host container $Containers
$cosmosDB = $cosmosDB_Name.ToLower()

foreach($container in $Containers)
{
  $Storedprocedures = get-childitem -path $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\Storedprocedures\$container\*.json" -Recurse -Force -Name
    foreach ($SP in $Storedprocedures)
    {
      write-host $SP
     $body = get-childitem -path $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\Storedprocedures\$container\$SP"

     Try {
      if ($SP -eq "sp_statusUpdaterAck.json")
      {
         az cosmosdb sql stored-procedure update --account-name $cosmosDB --resource-group $resourcegroup_name --body @$body --container-name $container --database-name $CosmosDatabaseName --name sp_statusUpdaterAck
         Write-Host "********** sp_statusUpdaterAck under $container Created/ Updated **********"
    }else 
    {
      az cosmosdb sql stored-procedure update --account-name $cosmosDB --resource-group $resourcegroup_name --body @$body --container-name $container --database-name $CosmosDatabaseName --name sp_statusUpdater
         Write-Host "********** sp_statusUpdater under $container Created/ Updated **********"
    }
     }
    catch 
    {
       $error
    }
   }
}

