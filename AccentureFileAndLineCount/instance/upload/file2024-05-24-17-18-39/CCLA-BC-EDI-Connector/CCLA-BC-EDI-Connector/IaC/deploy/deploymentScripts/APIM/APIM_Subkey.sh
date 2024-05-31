#!/bin/bash

# Define variables
subscriptionId=$1
resourceGroupName=$2
apim=$3
keyvaultName=$4

echo "Setting subscription"
az account set --subscription $subscriptionId
echo "getting subscriptionKey of APIM"

APIMID=$(az apim show -n $apim -g $resourceGroupName --query id -o tsv)
subscriptionKey=$(az rest --method post  --uri ${APIMID}/subscriptions/master/listSecrets?api-version=2022-08-01 --query primaryKey -o tsv)

echo "Uploading the key to Keyvault"
az keyvault secret set --vault-name $keyvaultName --name APIM-subscriptionKey --value $subscriptionKey
                       
