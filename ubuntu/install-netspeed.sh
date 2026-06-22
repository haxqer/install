#!/bin/bash
# ============================================================================
# install-netspeed.sh - 开启 BBR 网络加速
# ----------------------------------------------------------------------------
# 现代 Ubuntu（内核 >= 4.9）已内置 BBR，无需再像旧版那样编译内核模块。
# 本脚本仅通过 sysctl 开启 fq + bbr，幂等、无需重启、即时生效。
# ============================================================================

set -euo pipefail

# ─── 日志函数 ───────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    GREEN=$(printf '\033[32m'); YELLOW=$(printf '\033[33m'); RED=$(printf '\033[31m'); RESET=$(printf '\033[m')
else
    GREEN=""; YELLOW=""; RED=""; RESET=""
fi
log_info()  { echo -e "${GREEN}[INFO]${RESET} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ─── 检查 root ─────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "❌ 请使用 sudo 或 root 权限运行此脚本" >&2
    exit 1
fi

SYSCTL_FILE="/etc/sysctl.d/99-bbr.conf"

# ─── 检查内核版本 ──────────────────────────────────────────────────────────
kernel_version=$(uname -r)
kernel_major=$(echo "$kernel_version" | cut -d. -f1)
kernel_minor=$(echo "$kernel_version" | cut -d. -f2)

if (( kernel_major < 4 || (kernel_major == 4 && kernel_minor < 9) )); then
    log_error "当前内核 ${kernel_version} 不支持 BBR（需要 >= 4.9）"
    log_error "请先升级内核后重试"
    exit 1
fi
log_info "当前内核：${kernel_version}"

# ─── 加载并确认 BBR 可用 ───────────────────────────────────────────────────
modprobe tcp_bbr 2>/dev/null || true

available=$(sysctl -n net.ipv4.tcp_available_congestion_control 2>/dev/null || echo "")
if [[ " ${available} " != *" bbr "* ]]; then
    log_error "内核未提供 BBR 算法（available: ${available:-未知}）"
    log_error "该内核可能未编译 CONFIG_TCP_CONG_BBR，请更换支持 BBR 的内核"
    exit 1
fi

# ─── 写入 sysctl 配置 ──────────────────────────────────────────────────────
log_info "写入 BBR 配置到 ${SYSCTL_FILE}..."
cat > "${SYSCTL_FILE}" <<EOF
# === haxqer netspeed (BBR) ===
# 队列调度算法，配合 BBR 使用 fq 效果最佳
net.core.default_qdisc = fq
# 启用 BBR 拥塞控制算法
net.ipv4.tcp_congestion_control = bbr
EOF

# ─── 应用并校验 ────────────────────────────────────────────────────────────
sysctl --system >/dev/null 2>&1 || sysctl -p "${SYSCTL_FILE}" >/dev/null 2>&1 || true

cur_cc=$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "")
cur_qdisc=$(sysctl -n net.core.default_qdisc 2>/dev/null || echo "")

echo
log_info "当前拥塞控制算法：${cur_cc}"
log_info "当前队列调度算法：${cur_qdisc}"

if [[ "${cur_cc}" == "bbr" ]]; then
    log_info "✅ BBR 已成功开启"
else
    log_warn "BBR 未生效，当前为 ${cur_cc:-未知}，可尝试重启后再确认"
    exit 1
fi
