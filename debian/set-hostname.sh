#!/bin/bash
# ============================================================================
# set-hostname.sh - 设置主机名
#
# 用法: set-hostname.sh <hostname>
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

if [[ -z "${1:-}" ]]; then
    log_error "请指定主机名"
    echo "用法: $(basename "$0") <hostname>"
    echo "示例: $(basename "$0") web01.example.com"
    exit 1
fi

hostnamectl set-hostname "$1"
log_info "主机名已设置为: $1"
hostnamectl
