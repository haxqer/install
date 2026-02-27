#!/bin/bash
# ============================================================================
# remove-aliyun-monitor.sh - 卸载阿里云监控
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在卸载阿里云监控..."

# 卸载安骑士
if [[ -f /usr/local/aegis ]]; then
    wget -q http://update.aegis.aliyun.com/download/uninstall.sh && chmod +x uninstall.sh && ./uninstall.sh || true
    wget -q http://update.aegis.aliyun.com/download/quartz_uninstall.sh && chmod +x quartz_uninstall.sh && ./quartz_uninstall.sh || true
    rm -f uninstall.sh quartz_uninstall.sh
fi
rm -rf /usr/local/aegis

# 卸载 aliyun-service
systemctl disable aliyun.service 2>/dev/null || true
rm -f /usr/sbin/aliyun-service /usr/sbin/aliyun-service.backup /usr/sbin/aliyun_installer
rm -f /etc/systemd/system/aliyun.service /lib/systemd/system/aliyun.service

# 卸载云监控
ARCH=amd64
if [[ -f /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} ]]; then
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop 2>/dev/null || true
    /usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall 2>/dev/null || true
fi
if [[ -f /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh ]]; then
    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop 2>/dev/null || true
    /usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove 2>/dev/null || true
fi
rm -rf /usr/local/cloudmonitor

# 禁用服务
systemctl stop aliyun 2>/dev/null && systemctl disable aliyun 2>/dev/null || true
systemctl stop aegis 2>/dev/null && systemctl disable aegis 2>/dev/null || true
rm -f /system.slice/aegis.service
systemctl daemon-reload && systemctl reset-failed 2>/dev/null || true

log_info "✅ 阿里云监控卸载完成"