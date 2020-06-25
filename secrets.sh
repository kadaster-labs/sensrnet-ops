#!/bin/bash

function encrypt() {
    gpg --yes --batch --passphrase $PASSPHRASE -c secrets.json
}

function decrypt() {
    gpg -d --yes --batch -o secrets.json --passphrase $PASSPHRASE secrets.json.gpg
}

function printHelp() {
    echo "Usage:"
    echo "  secrets.sh <MODE> <PASSPHRASE>"
    echo "    <MODE>"
    echo "      - 'encrypt' - encrypt file 'secrets.json'"
    echo "      - 'decrypt' - decrypt file 'secrets.json'"
    echo ""
    echo "Examples:"
    echo "  secrets.sh encrypt helloworld"
    echo "  secrets.sh decrypt helloworld"
}

## Parse mode
if [[ $# -lt 2 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  PASSPHRASE=$2

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
