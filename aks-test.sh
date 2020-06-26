#!/bin/bash


function debug() {
  echo -e "${COLOR}  DEBUG ${*}${NC}"
}

function getCredentials() {
    echo "Get credentials for env [$ENV_NAME] - [$AKS_CLUSTER_NAME]"
    export SECRETS=$(./secrets.sh decrypt secrets.json.gpg $PASSPHRASE)
    # debug "$SECRETS"
    RESOURCE_GROUP=$(echo "$SECRETS" | jq -r '.test.aksClusters[] | select(.name == "aks-sensrnet-test") | .resourceGroup')
    debug "Resource group: $RESOURCE_GROUP"
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME
}

# colors
COLOR='\033[0;36m'
NC='\033[0m' # No Color

# properties
export ENV_NAME=test
export AKS_CLUSTER_NAME=aks-sensrnet-test

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  PASSPHRASE=$1
fi

SUBSCRIPTION=$(az account show | jq -r -c '.name')
debug "current subscription: $SUBSCRIPTION"
if [[ "$SUBSCRIPTION" != "etc-test" ]]; then
    echo "ERROR: Wrong subscription (should be 'etc-test' but is [$SUBSCRIPTION]"
    exit 1
fi



getCredentials
