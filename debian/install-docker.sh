#!/bin/bash

apt-get update -y \
&& apt-get install \
       ca-certificates \
       curl \
       gnupg \
       lsb-release -y \
&& mkdir -m 0755 -p /etc/apt/keyrings \
&& curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
&& chmod a+r /etc/apt/keyrings/docker.gpg \
&& echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
&& apt-get update -y \
&& apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
&& docker run hello-world

