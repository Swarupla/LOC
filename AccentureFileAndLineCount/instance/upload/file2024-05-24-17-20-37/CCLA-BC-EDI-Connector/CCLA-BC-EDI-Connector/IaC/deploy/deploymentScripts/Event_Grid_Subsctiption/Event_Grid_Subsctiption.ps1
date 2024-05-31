param(
$Event_resourcegroup_name,
$EventSubscriptionName,
$Eventfilter,
$EventEndpoint,
$Topic
)
Install-Module -Name Az.Resources -Scope CurrentUser -Force

##Creating Event grid subscription if not exists ##
Try{
    az eventgrid event-subscription create --name $EventSubscriptionName --source-resource-id $Topic --endpoint-type servicebusqueue --endpoint $EventEndpoint --advanced-filter eventType StringIn $Eventfilter
}
# Updating Event grid subscription If its already exists ##
catch 
{
  "Event Grid subscription already exists"
   write-host "Updating the event grid subscription"
   az eventgrid event-subscription update --name $EventSubscriptionName --source-resource-id $Topic --endpoint-type servicebusqueue --endpoint $EventEndpoint --advanced-filter eventType StringIn $Eventfilter
   write-host "Event grid subscription updated"
}