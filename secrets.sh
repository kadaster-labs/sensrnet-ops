#!/bin/bash

function encrypt() {
    gpg --yes --batch --passphrase $PASSPHRASE -c $FILE
}

function decrypt() {
    GPG_FILE=$FILE
    LENGTH=${#FILE}
    SRC_FILE=${FILE:0:$LENGTH-4}
    # echo "Writing $SRC_FILE"
    gpg -d --yes --batch --passphrase $PASSPHRASE $GPG_FILE
}

function printHelp() {
    echo "Usage:"
    echo "  secrets.sh <MODE> <FILE> <PASSPHRASE>"
    echo "    <MODE>"
    echo "      - 'encrypt' - encrypt file 'secrets.json'"
    echo "      - 'decrypt' - decrypt file 'secrets.json'"
    echo ""
    echo "Examples:"
    echo "  secrets.sh encrypt secrets.json helloworld"
    echo "  secrets.sh decrypt secrets.json.gpg helloworld"
}

## Parse mode
if [[ $# -lt 3 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  FILE=$2
  PASSPHRASE=$3

  case $MODE in
    encrypt )
      encrypt
      exit 0
      ;;
    decrypt )
      decrypt
      exit 0
      ;;
    * )
      printHelp
      exit 1
      ;;
  esac
fi
