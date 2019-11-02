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
        sudo

xsharp_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCy5SN7sEpZwF2XRtcOt7HlO8mPiYktjNgCHGdJ43eNtNVNmNKjABtCSdRKvxUmdd8NMnmlnbFcMbmVjnljiHhT/Y+Kn7Li0vLG0qKRZIyBkuVOAM4HRUsqRnRNcsw/dHzfKs6kX83sP3HOeckIyso12oJEw8o7uJkO0kM1Bcqc/QwnucAB+MtwJ5hvbEB09B9yuSieMyci3btR5MH7KYHBMv4A986/pvsrj3XUmyTv5INPTCbL5Zku3QroizePZ58ZGwwyN5e0+gfNnhPZLmvA8B9lajOZxl2x2qyEwLdFvNbeYXUJn0kU1lgCCq3xLW+lEUvgdOkqVLiwW5fVZWR xsharp@gmail.com"

mkdir -p ~/.ssh
echo ${xsharp_key} >> ~/.ssh/authorized_keys

# docker
apt-get update -y \
&& apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
&& curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -  \
&& add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" \
&& apt-get update -y \
&& apt-get install -y docker-ce docker-ce-cli containerd.io

#docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose \
&& docker-compose --version

#zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

