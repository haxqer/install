#!/bin/bash

apt update -y && \
  url="$(wget -qO- https://golang.org/dl/ | grep -oP '\/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1 )" && \
  latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )" && \
  echo "Downloading latest Go for AMD64: ${latest}" && \
  url="https://go.dev"${url} && \
  wget --quiet --continue --show-progress "${url}" && \
  rm -rf /usr/local/go && \
  tar -C /usr/local -xzf go"${latest}".linux-amd64.tar.gz && \
  echo "export PATH='$PATH':/usr/local/go/bin" >> ~/.profile && source ~/.profile && \
  go version