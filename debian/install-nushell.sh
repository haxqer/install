#!/bin/bash


apt update -y && \
    apt install build-essential procps curl file git pkg-config libssl-dev libxcb-composite0-dev libx11-dev -y && \
    curl https://sh.rustup.rs -sSf | sh && \
    source "$HOME/.cargo/env" && \
    echo 'source "$HOME/.cargo/env"' >> ~/.zshrc && \
    cargo install nu --features=extra
