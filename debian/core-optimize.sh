#!/bin/bash
# ============================================================================
# core-optimize.sh - Linux 内核参数 / 资源限制调优
# ----------------------------------------------------------------------------
# 现代化要点：
#   1. sysctl 改用 /etc/sysctl.d/ drop-in 文件（可重复覆盖、真正幂等、易卸载）
#   2. fd 上限同时配置 systemd（覆盖服务进程）和 limits.conf（覆盖登录会话）
#   3. nf_conntrack 仅在模块可用时写入，避免 sysctl 报错
#   4. 自动清理旧版残留（/etc/profile、/etc/sysctl.conf 中的旧 marker 块）
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

SYSCTL_FILE="/etc/sysctl.d/99-core-optimize.conf"
SYSTEMD_LIMIT_FILE="/etc/systemd/system.conf.d/99-limits.conf"
LIMITS_FILE="/etc/security/limits.d/99-haxqer.conf"

NOFILE=1048576   # 单进程最大打开文件数 (1M)
NPROC=1048576    # 单用户最大进程/线程数

# ─── 清理旧版残留 ──────────────────────────────────────────────────────────
# 旧版把配置追加到 /etc/sysctl.conf 和 /etc/profile，且 sysctl.conf 在
# `sysctl --system` 中最后加载，会覆盖 drop-in 文件，因此必须删除。
remove_old_block() {
    local file=$1 marker=$2
    if [[ -f "$file" ]] && grep -qF "$marker" "$file" 2>/dev/null; then
        # 删除从 marker 行到文件末尾的内容（旧版均追加在文件尾部）
        sed -i "/${marker}/,\$d" "$file"
        log_info "已清理旧配置：${file}"
    fi
}

remove_old_block /etc/sysctl.conf          "# === haxqer core-optimize ==="
remove_old_block /etc/profile              "# === haxqer ulimit ==="
remove_old_block /etc/security/limits.conf "# === haxqer limits ==="

# ─── sysctl 内核参数 ───────────────────────────────────────────────────────
log_info "写入内核参数到 ${SYSCTL_FILE}..."
cat > "${SYSCTL_FILE}" <<EOF
# === haxqer core-optimize ===

# ─── 文件系统 ───────────────────────────────────────────────
# 系统级最大打开文件数
fs.file-max = 6815744
# inotify 监视上限（Docker / 开发工具常用）
fs.inotify.max_user_instances = 8192
fs.inotify.max_user_watches = 524288

# ─── 网络：连接队列 ─────────────────────────────────────────
# 全局监听队列最大长度
net.core.somaxconn = 65535
# 网卡接收队列积压上限
net.core.netdev_max_backlog = 32768
# 未完成连接（SYN）队列上限
net.ipv4.tcp_max_syn_backlog = 262144

# ─── 网络：收发缓冲区 ───────────────────────────────────────
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
# TCP 缓冲区自动调节: min default max
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# ─── 网络：TCP 行为 ─────────────────────────────────────────
# 开启 TCP Fast Open（客户端 + 服务端）
net.ipv4.tcp_fastopen = 3
# 复用 TIME_WAIT 连接（安全，tcp_tw_recycle 已废弃不再使用）
net.ipv4.tcp_tw_reuse = 1
# TIME_WAIT 数量上限
net.ipv4.tcp_max_tw_buckets = 55000
# 缩短 FIN_WAIT2 超时
net.ipv4.tcp_fin_timeout = 15
# 空闲后不重置拥塞窗口（长连接吞吐更稳）
net.ipv4.tcp_slow_start_after_idle = 0
# 启用 MTU 探测，规避 PMTU 黑洞
net.ipv4.tcp_mtu_probing = 1
# SYN Flood 防护
net.ipv4.tcp_syncookies = 1
# keepalive 探测（更快回收死连接）
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
# 扩大本地端口范围
net.ipv4.ip_local_port_range = 1024 65535

# ─── 内存 ───────────────────────────────────────────────────
# 降低交换倾向
vm.swappiness = 10
# 降低 inode/dentry 缓存回收压力
vm.vfs_cache_pressure = 50
# 脏页回写阈值
vm.dirty_ratio = 10
vm.dirty_background_ratio = 5
EOF

# ─── 条件写入 nf_conntrack（仅模块可用时）────────────────────────────────
modprobe nf_conntrack 2>/dev/null || true
if [[ -e /proc/sys/net/netfilter/nf_conntrack_max ]]; then
    cat >> "${SYSCTL_FILE}" <<EOF

# ─── 防火墙连接跟踪（检测到 nf_conntrack 模块）──────────────
net.netfilter.nf_conntrack_max = 2621440
EOF
    log_info "检测到 nf_conntrack，已写入连接跟踪参数"
else
    log_warn "未加载 nf_conntrack 模块，跳过连接跟踪参数"
fi

log_info "应用 sysctl 参数..."
sysctl --system >/dev/null 2>&1 || true

# ─── systemd 服务 fd / 进程上限 ────────────────────────────────────────────
# /etc/profile 的 ulimit 对 systemd 启动的服务无效，必须用 systemd 配置。
log_info "写入 systemd 资源限制到 ${SYSTEMD_LIMIT_FILE}..."
mkdir -p "$(dirname "${SYSTEMD_LIMIT_FILE}")"
cat > "${SYSTEMD_LIMIT_FILE}" <<EOF
# === haxqer core-optimize ===
[Manager]
DefaultLimitNOFILE=${NOFILE}:${NOFILE}
DefaultLimitNPROC=${NPROC}:${NPROC}
EOF
# 让 systemd 重新读取管理器配置（已运行的服务需重启或重启系统后生效）
systemctl daemon-reexec 2>/dev/null || true

# ─── PAM 登录会话 fd / 进程上限 ────────────────────────────────────────────
log_info "写入 limits 配置到 ${LIMITS_FILE}..."
mkdir -p "$(dirname "${LIMITS_FILE}")"
cat > "${LIMITS_FILE}" <<EOF
# === haxqer core-optimize ===
*     soft nofile ${NOFILE}
*     hard nofile ${NOFILE}
root  soft nofile ${NOFILE}
root  hard nofile ${NOFILE}
*     soft nproc  ${NPROC}
*     hard nproc  ${NPROC}
root  soft nproc  ${NPROC}
root  hard nproc  ${NPROC}
EOF

echo
log_info "✅ 内核与资源限制优化完成"
log_warn "提示：systemd 服务的新 fd 上限需重启服务或重启系统后完全生效"
