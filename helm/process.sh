#!/bin/sh
set -e

if [ "$1" = "" ]; then
    echo "Missing environment"
    exit
else
    if [ "$2" = "" ]; then
        echo "Missing action: install|template"
        exit
    fi

    echo "Processing '$1'-'$2' heml chart..."
    helm $2 --set namespace=$1 --set google_client_id=$GOOGLE_CLIENT_ID \
        reasonedart-deployment .
fi