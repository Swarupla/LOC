#!/bin/bash

# Define variables
subscriptionId=$1
resourceGroupName=$2
logicAppName=$3
functionAppName=$4

az account set --subscription $subscriptionId

echo "getting Function app's Outbound ip address"
outboundIPs=$(az functionapp show --name $functionAppName --resource-group $resourceGroupName --query possibleOutboundIpAddresses -o tsv)


json="["
for ip in $(echo $outboundIPs | tr "," "\n"); do
    json+="{\"addressRange\": \"$ip/32\"},"
done
# Remove the trailing comma
json="${json%,}"
json+="]"

echo "updating trigger and Action in workflow"

az resource update --resource-group $resourceGroupName --name $logicAppName --resource-type Microsoft.Logic/workflows --set properties.accessControl.triggers.allowedCallerIpAddresses="$json"
az resource update --resource-group $resourceGroupName --name $logicAppName --resource-type Microsoft.Logic/workflows --set properties.accessControl.actions.allowedCallerIpAddresses="$json"