#!/bin/sh
set -e

if [ "$1" = "" ]; then
    echo "Missing environment"
    exit
else
    echo "Uninstalling '$1' heml chart..."
    helm uninstall reasonedart-deployment
fi