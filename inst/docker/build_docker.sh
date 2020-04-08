#!/bin/bash

# Author: Patty Rosendaal
# Date: 23-1-2020

# This script builds a Docker image for an RStudio server from the supplied Dockerfile.
# Not supplying Dockerfile path will use '.' current directory.

# User input
while getopts i:n: aflag
do
case "${aflag}"
in
i) DOCKERFILE=${OPTARG};;
n) OUTNAME_IMAGE=${OPTARG};;
esac
done

${DOCKERFILE:=.}

set -e
err_report() {
    echo "Error on line $1"
    echo "Please check that supplied image outname and Dockerfile are correct"
}
trap 'err_report $LINENO' ERR

# Build command
sudo docker build --rm --force-rm -t ${OUTNAME_IMAGE} ${DOCKERFILE}
status=$?
echo "Command exit status: ${status}"
