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
        default-jdk \
        openjfx \
        curl \
        sudo

haxqer_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2xwdBPeyJaJgddhu4cmYD2/s70Q/WeOrWqzEre3R90FTtjZtsBkx62oTiX+10gL/ZS3P4HGdkiHty2yV0SLJtpaP+ZCVu1aJyIoZrjHGAZNsJGD6ocPlnY47pmZERHxEebpQrJYzdUye2T7wIRZ+kkjHAcOkIclHQPanf/rVjpvQJ1yqaKS9zGHnEDFaptvHbDJQNS2NhhM0/NgLHHLxpIx4uHj6wMRdbkisiSyQhkDRne2SNE+TBV/w98vQIOff0n2wMlo8JV/kRdRBtBq35FOl0CiihNe5bhUlQWvqPgDqyUTJ9CARIk3+lwJjDPS5gB4Ba3N2j0HTYqW9XEN1r haxqer"

mkdir -p ~/.ssh
echo ${haxqer_key} >> ~/.ssh/authorized_keys

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

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

