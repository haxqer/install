#!/bin/bash

apt update -y && \
    apt install -y \
        curl

#curl -Ls https://install.direct/go.sh | bash
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
