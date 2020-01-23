#!/bin/bash

# Author: Patty Rosendaal
# Date: 23-1-2020

# This script starts a Docker container RStudio server from a previously built image.

# EXAMPLE: bash run_docker.sh -p 28787 -n testcont -u 1002 -w Pass -m /data -i testname5.
# This command runs RStudio server from image 'testname5' on IP:28787.
# The container name is 'testcont'. Login with username 'rstudio' and password 'Pass'.
# User ID is set to 1002, allowing this user to write/open their files mounted from the host in the container (/data mounted here).

# User input
while getopts p:n:u:w:m:i: aflag
do
case "${aflag}"
in
p) PORT=${OPTARG};;
n) CONTAINER_NAME=${OPTARG};;
u) USER_ID=${OPTARG};;
w) PASSWD=${OPTARG};;
m) MOUNT=${OPTARG};;
i) IMAGE=${OPTARG};;
esac
done

# For testing purposes, keep commented
# PORT=28787
# CONTAINER_NAME=testcont
# USER_ID=1002
# PASSWD=Pass
# MOUNT=/data
# IMAGE=testname5

set -e
err_report() {
    echo "Error on line $1"
    echo "Please check that supplied arguments are correct and no container of/on the same name/port is running."
    echo "An example usage of this script is available in the script itself and in the package documentation."
}
trap 'err_report $LINENO' ERR

# Running run container command
if [ -z ${MOUNT+x} ]; then 
  sudo docker run -d --rm -p ${PORT}:8787 --name ${CONTAINER_NAME} \
  -e USERID=${USER_ID} -e PASSWORD=${PASSWD} ${IMAGE};
else 
  sudo docker run -d --rm -p ${PORT}:8787 --name ${CONTAINER_NAME} \
  -e USERID=${USER_ID} -e PASSWORD=${PASSWD} \
  -v ${MOUNT}:/home/rstudio/mount ${IMAGE}
fi
status=$?
echo "Command exit status: ${status}"