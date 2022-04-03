#!/bin/bash

yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
&& yum install -y yum-utils \
&& yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo \
&& yum install -y docker-ce docker-ce-cli containerd.io \
&& systemctl start docker \
&& systemctl enable docker

