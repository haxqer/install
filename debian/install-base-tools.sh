#!/bin/bash
# ============================================================================
# install-base-tools.sh - 安装基础工具包
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装基础工具包..."

apt update -y && \
    apt install -y \
        htop \
        build-essential \
        net-tools \
        dnsutils \
        sysstat \
        dstat \
        git \
        tree \
        zsh \
        curl \
        vim \
        conntrack \
        ipvsadm \
        ipset \
        jq \
        apache2-utils \
        open-vm-tools \
        bash-completion \
        openssh-server \
        sudo \
        nethogs \
        unzip \
        psmisc \
        proxychains \
        screen \
        lvm2 \
        socat \
        ebtables \
        rsync \
        etherwake \
        nmap \
        nload \
        iftop \
        bmon \
        iperf3 \
        tmux \
        gzip \
        wget \
        xclip

log_info "✅ 基础工具包安装完成"
