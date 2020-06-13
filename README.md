# structural_colours
This is the repo for the HU - Hoekmine "Structural Colours" Intership project. In this repo the structural colours package is available. This package can be used for obtaining and processing shotgun metagenomic data.

# Installation
## Docker install
A dockerfile is available in this package to create a container to run the package in. The files in the inst/docker folder are used and these can be downloaded or the repo can be forked to your system to access them. Here is an instruction on how to build the Docker container to run this package in.

**1**: Install Docker. This can be done by running the ‘install_docker.sh’ script. The script can be run on the command line using the command ‘bash install_docker.sh’.

**2**: Create a Docker image. A Docker image is built from a Dockerfile. This image will contain the software needed to build the container. The image can be built using the ‘build_docker.sh’ script. The script can be run on the command line using the command ‘bash build_docker.sh (flags)’, with the options needed in the following flags:
-	i: Path to the Dockerfile, e.g. ‘/home/rstudio/DockerFile’. Use the Dockerfile from the repo to run this package in.
-	n: Name of output Docker image, e.g. ‘image1’.

**3**: Build Docker RStudio server container. Using the Docker image a container running the software can be made. The container can be built using the ‘run_docker.sh’ script. The script can be run on the command line using the command ‘bash run_docker.sh (flags)’, with the options needed in the following flags:
-	p: Port to run container in, e.g. ‘28787’. This will run the container on IP:28787.
-	n: Name of output container, e.g. ‘container1’.
-	u: User ID, you can check your using ID by running ‘echo $UID’. This is necessary for sharing file permissions with the host system in case you are mounting a directory to the container.
-	w: Password, set a password for the RStudio server.
-	m: Mount directory, e.g. ‘/datafolder’. The path to the directory given on the host will be mounted on the container as ‘/mount’.
-	i: Image name to run container of, e.g. ‘image1’

Note: the -m flag is not mandatory; it is not necessary to mount a directory to the container. Do keep in mind that files created in the container are ephemeral unless the directory is mounted to the host.

