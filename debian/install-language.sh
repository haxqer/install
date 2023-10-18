#!/bin/bash

apt update -y && \
    apt install -y \
        fonts-noto-color-emoji


dpkg-reconfigure locales
locale -a
