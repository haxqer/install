#!/bin/bash


apt update -y && \
    apt install -y \
        curl

curl -Ls https://install.direct/go.sh | bash

