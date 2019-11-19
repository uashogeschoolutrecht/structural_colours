#!/bin/bash
# This is s simple docker run command, broken up so you can read each bit
# -d flag runs in detatched mode
# use -it to start in interactive mode
# --rm removes the container on exit

#sudo docker run -d --rm \
#    -p 28787:8787 \                         # map ports
#    --name hello-world2 \                   # name container
#    -e USERID=$UID \                        # you need to share a UID so you can write to mount file on host
#    -e PASSWORD=SoSecret! \                   # set rstudio password - user is rstudio
#    -v $DATA_DIR:/home/rstudio/Data \       # mount data directory to pick up changes or write to host
#       rstudio/hello-world                  # the name of the image


#sudo docker build --rm --force-rm -t rstudio/pack-testing1 .
# docker volume create --driver sapk/plugin-rclone --opt config="$(base64 ~/.config/rclone/rclone.conf)" --opt remote=HPC_cloud: --name research_drive
PASSWD=SoSecret
PACK_DIR=${PWD}/scpackage
DRIVE_DIR=/home/patty_rosendaal/local_storage

sudo docker run -d --rm -p 28786:8787 --name geo_testing2 -e USERID=rstudio -e PASSWORD=$PASSWD \
-v $PACK_DIR:/home/rstudio/scpackage -v $DRIVE_DIR:/home/rstudio/research_drive -v /data:/home/rstudio/data rstudio/pack-testing2

#

#sudo docker exec -it <container-id> bash
#adduser <username>