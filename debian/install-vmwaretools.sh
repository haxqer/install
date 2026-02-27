#!/bin/bash
# ============================================================================
# install-vmwaretools.sh - 安装 VMware Tools (open-vm-tools)
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在安装 open-vm-tools..."
apt update -y && apt install -y open-vm-tools

log_info "✅ VMware Tools 安装完成"
