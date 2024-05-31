param(
     [Parameter(Mandatory=$true,HelpMessage="Resource Group must already exist")]
     [string]$resourceGroupName,
     
     [Parameter(Mandatory=$true,HelpMessage="integration account name")]
     [string]$integrationAccountName,
     
     [Parameter(Mandatory=$true,HelpMessage="schema name")]
     [string[]]$schemaName,

     [Parameter(Mandatory=$true,HelpMessage="map name")]
     [string[]]$mapName,
 
     [Parameter(Mandatory=$true,HelpMessage="Tenant ID of a app registration")]
     [string]$tenantId,
 
     [Parameter(Mandatory=$true,HelpMessage="subscriptionId")]
     [string]$subscriptionId,

     [Parameter(Mandatory=$true,HelpMessage="BuildId")]
     [int]$buildId

 )


Set-AzContext -Tenant $tenantId -SubscriptionId $subscriptionId

Try {
    # Get existing Integration Account
    $intaccount = Get-AzIntegrationAccount -ResourceGroupName $resourceGroupName -Name $integrationAccountName -ErrorAction Stop
    Write-Host "**************************************************************"
    Write-Host "********** Integration Account is already existed ************"
    Write-Host "**************************************************************"

} Catch {
    Write-Host "$integrationAccountName does not exist"
    Write-Host "Creating $integrationAccountName"
    $intaccount = New-AzIntegrationAccount -ResourceGroupName $resourceGroupName -Name $integrationAccountName -Location "EastUS" -Sku "Basic"
    Write-Host "****************************************************"
    Write-Host "********** Integration Account Created ************"
    Write-Host "****************************************************"
}

Write-Host "`n`n`n`n"
Write-Host "********** Integration Account Schemas **********"
Write-Host "****************************************************"

foreach($schema in $schemaName){
    Try {
        $intschema = New-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $schema -SchemaFilePath  $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\schemas\"$schema".xsd" -ErrorAction Stop
        Write-Host "********** $schema Created **********"
    } Catch {
        Write-Host "`n$schema already exist"
        Write-Host "Updating $schema"
        $intschema = Set-AzIntegrationAccountSchema -ResourceGroupName $resourceGroupName -Name $integrationAccountName -SchemaName $schema -SchemaFilePath  $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\schemas\"$schema".xsd" -Force -Confirm:$false
        Write-Host "********** $schema Updated **********"
    }
}

Write-Host "`n`n`n`n"
Write-Host "********** Integration Account Maps **********"

foreach($map in $mapName){
       Try {
        $intmap = New-AzIntegrationAccountMap -MapFilePath $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\maps\"$map".xslt"  -MapName $map -MapType Xslt -Name $integrationAccountName -ResourceGroupName $resourceGroupName -ErrorAction Stop
        Write-Host "********** $map Created **********"
    } Catch {
        Write-Host "`n$map already exist"
        Write-Host "Updating $map"
        $intmap = Set-AzIntegrationAccountMap -MapFilePath $env:AGENT_BUILDDIRECTORY"\ediintegration-"$buildId"\maps\"$map".xslt"  -MapName $map -MapType Xslt -Name $integrationAccountName -ResourceGroupName $resourceGroupName  -Force -Confirm:$false
        Write-Host "********** $map Updated **********"
    }
}

