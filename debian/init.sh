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
        sudo

haxqer_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2xwdBPeyJaJgddhu4cmYD2/s70Q/WeOrWqzEre3R90FTtjZtsBkx62oTiX+10gL/ZS3P4HGdkiHty2yV0SLJtpaP+ZCVu1aJyIoZrjHGAZNsJGD6ocPlnY47pmZERHxEebpQrJYzdUye2T7wIRZ+kkjHAcOkIclHQPanf/rVjpvQJ1yqaKS9zGHnEDFaptvHbDJQNS2NhhM0/NgLHHLxpIx4uHj6wMRdbkisiSyQhkDRne2SNE+TBV/w98vQIOff0n2wMlo8JV/kRdRBtBq35FOl0CiihNe5bhUlQWvqPgDqyUTJ9CARIk3+lwJjDPS5gB4Ba3N2j0HTYqW9XEN1r haxqer"

mkdir -p ~/.ssh
echo ${haxqer_key} >> ~/.ssh/authorized_keys

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# docker
${DIR}/install-docker.sh
${DIR}/install-docker-compose.sh


#zsh
#sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
${DIR}/install-zsh.sh
