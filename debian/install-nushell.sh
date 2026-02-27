#!/bin/bash
# ============================================================================
# install-nushell.sh - 安装 Nushell (通过 Rust cargo)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 Nushell 及其依赖..."
apt update -y && \
    apt install -y build-essential procps curl file git pkg-config libssl-dev libxcb-composite0-dev libx11-dev && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source "$HOME/.cargo/env" && \
    echo 'source "$HOME/.cargo/env"' >> ~/.zshrc && \
    cargo install nu --features=extra

log_info "✅ Nushell 安装完成"
