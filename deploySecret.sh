#!/bin/bash

# default settings
export VERBOSE=false

function printHelp() {
    echo "Usage:"
    echo "  deploySecret.sh <name> <username-file> <password-file> [FLAGS]"
    echo ""
    echo "    Flags:"
    echo "    -p <passphrase> - Passphrase of 'secrets.json' file"
    echo "    -verbose - Print debug info"
    echo ""
    echo "Examples:"
    echo "  deploySecret.sh my-secret user.txt pw.txt -p helloworld"
}

function debug() {
  if [[ "$VERBOSE" = true ]]; then
    echo -e "${COLOR_CYAN}  DEBUG ${*}${NC}"
  fi
}

function error() {
  echo -e "${COLOR_RED}ERROR ${*}${NC}"
}

function strippedFilename()
{
    local __resultvar=$1
    local __filename=$2
    local __length=${#__filename}
    if [[ "$__resultvar" ]]; then
        eval $__resultvar=${__filename:0:$__length-4}
    else
        echo "ERROR: Getting filename from [$__filename]"
    fi
}

function deploySecret() {
    if [[ "$PASSPHRASE" == "" ]]; then
      echo "ERROR: PASSPHRASE is empty! (use option -p)"
      exit 1
    fi

    echo "Deploy secret [$NAME]"
    strippedFilename USER_FILE "$USER"
    debug "$USER_FILE"
    ./secrets.sh decrypt $USER $PASSPHRASE > $USER_FILE

    if [[ ! -f "$USER_FILE" ]]; then
      error "$USER_FILE could not be found!"
      exit 1
    fi

    strippedFilename PASS_FILE "$PASS"
    debug "$PASS_FILE"
    ./secrets.sh decrypt $PASS $PASSPHRASE > $PASS_FILE
    echo

    if [[ ! -f "$PASS_FILE" ]]; then
      error "$PASS_FILE could not be found!"
      exit 1
    fi

    kubectl create secret generic "$NAME" --from-file="./$USER_FILE" --from-file="./$PASS_FILE"

    kubectl get secrets

    echo
    echo "Cleaning up local files ..."
    rm $USER_FILE $PASS_FILE
    echo
    echo "done."
}

# colors
COLOR_CYAN='\033[0;36m'
COLOR_RED='\033[0;31m'
NC='\033[0m' # No Color

# properties

## Parse mode
if [[ $# -lt 3 ]] ; then
  printHelp
  exit 0
else
  NAME=$1
  USER=$2
  PASS=$3
  shift 3
fi

# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp
    exit 0
    ;;
  -p )
    PASSPHRASE="$2"
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

CURRENT_CONTEXT=$(kubectl config current-context)
echo "Using current context: $CURRENT_CONTEXT"
echo


deploySecret
