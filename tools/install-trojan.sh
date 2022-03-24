#!/bin/bash

apt update -y && \
    apt install -y \
        curl

bash -c "$(curl -fsSL https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

