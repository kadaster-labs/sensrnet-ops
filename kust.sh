#!/bin/bash

# default settings
export VERBOSE=false

function printHelp() {
  echo "Usage:"
  echo "  ops.sh <MODE> [FLAGS]"
  echo "    <MODE>"
  echo "      - 'apply' - kubectl apply with kustomize"
  echo "      - 'delete' - kubectl delete with kustomize"
  echo ""
  echo "    Flags:"
  echo "    -e <env name> - Environment name: test or prod"
  echo "    -f <folder> - Folder to kustomization root"
  echo ""
  echo "Examples:"
  echo "  ops.sh apply -f kafka"
  echo "  ops.sh delete -f kafka"
}

function debug() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "${COLOR_CYAN}  DEBUG ${*}${NC}"
  fi
}

function error() {
  echo -e "${COLOR_RED}ERROR ${*}${NC}"
}

function applyWithKustomize() {
  echo "Kustomize and kubectl apply [$FOLDER]"
  echo
  KUSTOMIZE_PATH=$FOLDER/overlays/$ENV_NAME/
  debug "building $KUSTOMIZE_PATH"
  debugKustomize $KUSTOMIZE_PATH
  kustomize build $KUSTOMIZE_PATH | kubectl apply -f -
}

function deleteWithKustomize() {
  echo "Kustomize and kubectl delete [$FOLDER]"
  echo
  KUSTOMIZE_PATH=$FOLDER/overlays/$ENV_NAME/
  debug "building $KUSTOMIZE_PATH"
  debugKustomize $KUSTOMIZE_PATH
  kustomize build $KUSTOMIZE_PATH | kubectl delete -f -
}

function debugKustomize() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "${COLOR_CYAN}"
    kustomize build $KUSTOMIZE_PATH

    if [ $? -ne 0 ]; then
      echo -e "${NC}"
      echo "ERROR !!! Building kustomize"
      exit 1
    fi
    echo -e "${NC}"

  fi
}

# colors
COLOR_CYAN='\033[0;36m'
COLOR_RED='\033[0;31m'
NC='\033[0m' # No Color

# properties

## Parse mode
if [[ $# -lt 1 ]]; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse flags
while [[ $# -ge 1 ]]; do
  key="$1"
  case $key in
  -h)
    printHelp
    exit 0
    ;;
  -e )
    ENV_NAME="$2"
    shift
    ;;
  -f)
    FOLDER="$2"
    shift
    ;;
  -v)
    VERSION="$2"
    shift
    ;;
  -verbose)
    VERBOSE=true
    shift
    ;;
  *)
    echo
    echo "Unknown flag: $key"
    echo
    printHelp
    exit 1
    ;;
  esac
  shift
done

CURRENT_CONTEXT=$(kubectl config current-context)
echo "Using current context: $CURRENT_CONTEXT"
echo

CONTEXT_NAME="$ENV_NAME.$CLUSTER_NAME"

if [[ "$ENV_NAME" == "" ]]; then
  echo "WARN: option environment is empty: using 'local' as default environment"
  echo
  ENV_NAME=local
fi

if [ "${MODE}" == "apply" ]; then
  applyWithKustomize
elif [ "${MODE}" == "delete" ]; then
  deleteWithKustomize
else
  printHelp
  exit 1
fi
