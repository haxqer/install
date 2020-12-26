#!/bin/bash

yum update -y && \
    yum install epel-release -y && \
    yum install -y \
        htop \
        net-tools \
        git \
        zsh \
        vim \
        conntrack \
        ipvsadm \
        ipset \
        open-vm-tools \
        bash-completion \
        nfs-common \
        unzip \
        g++ \
        nethogs

