#!/bin/bash -eu

if [ "$#" -ne 1 ]; then
	    echo "Usage: $0 path-to-file.json|yaml"
	        exit 1
fi

file=$1
nl=$'\n'

cat $file

cat <<EOF
$nl
EOF

