#!/bin/bash

apt update -y && \
    apt install -y \
        htop \
        net-tools \
        sysstat \
        dstat \
        git \
        tree \
        zsh \
        htop \
        curl \
        vim \
        conntrack \
        ipvsadm \
        ipset \
        jq \
        apache2-utils \
        sudo

pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCy5SN7sEpZwF2XRtcOt7HlO8mPiYktjNgCHGdJ43eNtNVNmNKjABtCSdRKvxUmdd8NMnmlnbFcMbmVjnljiHhT/Y+Kn7Li0vLG0qKRZIyBkuVOAM4HRUsqRnRNcsw/dHzfKs6kX83sP3HOeckIyso12oJEw8o7uJkO0kM1Bcqc/QwnucAB+MtwJ5hvbEB09B9yuSieMyci3btR5MH7KYHBMv4A986/pvsrj3XUmyTv5INPTCbL5Zku3QroizePZ58ZGwwyN5e0+gfNnhPZLmvA8B9lajOZxl2x2qyEwLdFvNbeYXUJn0kU1lgCCq3xLW+lEUvgdOkqVLiwW5fVZWR xsharp@gmail.com"

mkdir -p ~/.ssh
echo ${pub_key} >> ~/.ssh/authorized_keys

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# docker
${DIR}/install-docker.sh
${DIR}/install-docker-compose.sh


#zsh
#sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
${DIR}/install-zsh.sh
