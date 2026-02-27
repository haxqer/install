#!/bin/bash
# ============================================================================
# add-swap.sh - 创建 swap 分区
#
# 用法:
#   add-swap.sh            默认创建 1G swap
#   add-swap.sh --size 2G  指定 swap 大小
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

SWAP_SIZE="1G"
if [[ "${1:-}" == "--size" && -n "${2:-}" ]]; then
    SWAP_SIZE="$2"
fi

SWAP_FILE="/var/swapfile"

# 检查是否已存在 swap
if swapon --show | grep -q "${SWAP_FILE}"; then
    log_warn "Swap 文件 ${SWAP_FILE} 已存在且已激活，跳过"
    exit 0
fi

log_info "创建 ${SWAP_SIZE} swap 文件..."
fallocate -l "${SWAP_SIZE}" "${SWAP_FILE}" || dd if=/dev/zero of="${SWAP_FILE}" bs=1M count=$((${SWAP_SIZE%G} * 1024))
chmod 600 "${SWAP_FILE}"
mkswap "${SWAP_FILE}"
swapon "${SWAP_FILE}"

# 幂等写入 fstab
if ! grep -q "${SWAP_FILE}" /etc/fstab; then
    echo "${SWAP_FILE}    swap    swap    defaults    0 0" >> /etc/fstab
fi

log_info "✅ Swap 创建完成 (${SWAP_SIZE})"
free -h
