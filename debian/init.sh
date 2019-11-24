#!/bin/bash

# working directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


# install base tools
${DIR}/install-base-tools.sh


# add public key
${DIR}/add-pub-key.sh


# docker
${DIR}/install-docker.sh
${DIR}/install-docker-compose.sh


# zsh
${DIR}/install-zsh.sh


# some images
${DIR}/pull-k8s-images.sh