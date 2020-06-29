#!/bin/bash

# default settings
export VERBOSE=false

function printHelp() {
    echo "Usage:"
    echo "  ops.sh <MODE> [FLAGS]"
    echo "    <MODE>"
    echo "      - 'get-credentials' - Get credentials for AKS cluster"
    echo "      - 'select-cluster' - Select AKS cluster in local kubectl context"
    echo ""
    echo "    Flags:"
    echo "    -e <env name> - Environment name: test or prod"
    echo "    -c <cluster name> - AKS cluster name"
    echo "    -p <passphrase> - Passphrase of 'secrets.json' file"
    echo ""
    echo "Examples:"
    echo "  ops.sh getCredentials -p helloworld -c aks-sensrnet-test"
}

function debug() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "${COLOR}  DEBUG ${*}${NC}"
  fi
}

function getCredentials() {
    if [[ "$PASSPHRASE" == "" ]]; then
      echo "ERROR: PASSPHRASE is empty! (use option -p)"
      exit 1
    fi

    echo "Get credentials for env [$ENV_NAME] - [$CLUSTER_NAME]"
    export SECRETS=$(./secrets.sh decrypt secrets.json.gpg $PASSPHRASE)
    debug "$SECRETS"
    RESOURCE_GROUP=$(echo "$SECRETS" | jq -r '.test.aksClusters[] | select(.name == "aks-sensrnet-test") | .resourceGroup')
    debug "Resource group: $RESOURCE_GROUP"

    if [[ "$RESOURCE_GROUP" == "" ]]; then
      echo "ERROR: RESOURCE_GROUP is empty! (something went wrong with decrypting secrets? try with option -verbose)"
      exit 1
    fi

    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --context "$CONTEXT_NAME"
}

function selectCluster() {
    echo "Selecting AKS cluster for kubectl: $CONTEXT_NAME"
    kubectl config use-context $CONTEXT_NAME
}

# colors
COLOR='\033[0;36m'
NC='\033[0m' # No Color

# properties

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp
    exit 0
    ;;
  -e )
    ENV_NAME="$2"
    shift
    ;;
  -c )
    CLUSTER_NAME="$2"
    shift
    ;;
  -p )
    PASSPHRASE="$2"
    shift
    ;;
  -v )
    VERSION="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    shift
    ;;
  * )
    echo
    echo "Unknown flag: $key"
    echo
    printHelp
    exit 1
    ;;
  esac
  shift
done

SUBSCRIPTION=$(az account show | jq -r -c '.name')
debug "current subscription: $SUBSCRIPTION"
if [[ "$SUBSCRIPTION" != "etc-test" ]]; then
    echo "ERROR: Wrong subscription (should be 'etc-test' but is [$SUBSCRIPTION]"
    echo
    echo "Run: az account set --subscription \"etc-test\""
    exit 1
fi


if [[ "$ENV_NAME" == "" ]]; then
  echo "WARN: option environment is empty: using 'test' as default environment"
  ENV_NAME=test
fi

if [[ "$CLUSTER_NAME" == "" ]]; then
  echo "WARN: option cluster name is empty: using 'aks-sensrnet-test' as default cluster"
  CLUSTER_NAME=aks-sensrnet-test
fi

CONTEXT_NAME="$ENV_NAME.$CLUSTER_NAME"

if [ "${MODE}" == "get-credentials" ]; then
  getCredentials
elif [ "${MODE}" == "select-cluster" ]; then
  selectCluster
else
  printHelp
  exit 1
fi
