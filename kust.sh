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
  pushd $FOLDER
  kustomize build overlays/local/ | kubectl apply -f -
  popd
}

function deleteWithKustomize() {
  echo "Kustomize and kubectl delete [$FOLDER]"
  echo
  pushd $FOLDER
  kustomize build overlays/local/ | kubectl delete -f -
  popd
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

if [ "${MODE}" == "apply" ]; then
  applyWithKustomize
elif [ "${MODE}" == "delete" ]; then
  deleteWithKustomize
else
  printHelp
  exit 1
fi
