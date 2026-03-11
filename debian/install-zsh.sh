#!/bin/bash
# ============================================================================
# install-zsh.sh - 安装 Zsh + Oh My Zsh
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 zsh..."
apt update -y && apt install -y zsh

log_info "正在安装 Oh My Zsh..."
# 非交互式安装 oh-my-zsh，不自动切换 shell
export RUNZSH=no
# `--unattended` 会强制覆盖 CHSH 为 no，所以我们要在安装后手动切换
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log_info "正在设置 Zsh 为默认 Shell..."
usermod -s /usr/bin/zsh root

log_info "✅ Zsh + Oh My Zsh 安装完成"
log_info "请运行 'exec zsh' 或重新登录以使用 zsh"
