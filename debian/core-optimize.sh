#!/bin/bash
# ============================================================================
# core-optimize.sh - Linux 内核参数调优
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

# ─── 内核参数调优 ──────────────────────────────────────────────────────────
SYSCTL_MARKER="# === haxqer core-optimize ==="

if grep -q "${SYSCTL_MARKER}" /etc/sysctl.conf 2>/dev/null; then
    log_warn "/etc/sysctl.conf 已包含优化配置，跳过"
else
    log_info "写入内核参数到 /etc/sysctl.conf..."
    cat >> /etc/sysctl.conf <<EOF

${SYSCTL_MARKER}
# TIME_WAIT 数量上限
net.ipv4.tcp_max_tw_buckets = 20000
# 全局监听队列最大长度
net.core.somaxconn = 65535
# 未确认连接请求队列最大数目
net.ipv4.tcp_max_syn_backlog = 262144
# 网络接口接收队列最大数目
net.core.netdev_max_backlog = 30000
# 系统所有进程可打开文件数
fs.file-max = 6815744
# 防火墙跟踪表大小 (防火墙未开启时会报错，可忽略)
net.netfilter.nf_conntrack_max = 2621440
EOF
    sysctl -p || true
fi

# ─── 打开文件数优化 ────────────────────────────────────────────────────────
PROFILE_MARKER="# === haxqer ulimit ==="

if grep -q "${PROFILE_MARKER}" /etc/profile 2>/dev/null; then
    log_warn "/etc/profile 已包含 ulimit 配置，跳过"
else
    log_info "写入 ulimit 配置到 /etc/profile..."
    cat >> /etc/profile <<EOF

${PROFILE_MARKER}
ulimit -HSn 102400
EOF
fi

LIMITS_MARKER="# === haxqer limits ==="

if grep -q "${LIMITS_MARKER}" /etc/security/limits.conf 2>/dev/null; then
    log_warn "/etc/security/limits.conf 已包含配置，跳过"
else
    log_info "写入 limits 配置到 /etc/security/limits.conf..."
    cat >> /etc/security/limits.conf <<EOF

${LIMITS_MARKER}
* soft nofile 1024000
* hard nofile 1024000
root soft nofile 1024000
root hard nofile 1024000
EOF
fi

log_info "✅ 内核优化完成"
