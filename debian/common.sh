#!/bin/bash
# ============================================================================
# common.sh - 公共函数库
# 被其他脚本 source 引用，不独立执行
# 用法: source "$(dirname "$0")/common.sh"
# ============================================================================

set -euo pipefail

# ─── 颜色变量 ───────────────────────────────────────────────────────────────
setup_color() {
    if [[ -t 1 ]]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        GRAY=$(printf '\033[0;90m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        GRAY=""
        RESET=""
    fi
}

# ─── 日志函数 ───────────────────────────────────────────────────────────────
log_info()  { echo -e "${GREEN:-}[INFO]${RESET:-} $*"; }
log_warn()  { echo -e "${YELLOW:-}[WARN]${RESET:-} $*"; }
log_error() { echo -e "${RED:-}[ERROR]${RESET:-} $*" >&2; }

# 进度日志: log_step 1 3 "正在安装依赖..."
log_step() {
    local current=$1 total=$2 msg=$3
    echo -e "\n${BLUE:-}[${current}/${total}]${RESET:-} ${msg}"
}

# ─── 检查函数 ───────────────────────────────────────────────────────────────
require_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ 请使用 sudo 或 root 权限运行此脚本" >&2
        exit 1
    fi
}

require_x86_64() {
    if [[ $(uname -m 2>/dev/null) != x86_64 ]]; then
        echo "❌ 此脚本仅支持 x86_64 架构" >&2
        exit 1
    fi
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

# ─── 工具函数 ───────────────────────────────────────────────────────────────

# 获取调用脚本所在目录（而非 common.sh 所在目录）
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" >/dev/null 2>&1 && pwd
}

# 确认提示: confirm "是否继续?" && do_something
confirm() {
    local prompt="${1:-确认?} [Y/n] "
    printf "%s" "$prompt"
    read -r opt
    case $opt in
        n*|N*) return 1 ;;
        *) return 0 ;;
    esac
}

# 初始化颜色
setup_color
