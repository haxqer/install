#!/bin/bash
# ============================================================================
# remove-tencent-monitor.sh - 卸载腾讯云监控
# ============================================================================

source "$(dirname "$0")/common.sh"
require_root

log_info "正在卸载腾讯云监控..."

# 清理 crontab
crontab -r 2>/dev/null || true

# 运行官方卸载脚本
[[ -f /usr/local/qcloud/stargate/admin/uninstall.sh ]] && /usr/local/qcloud/stargate/admin/uninstall.sh || true
[[ -f /usr/local/qcloud/YunJing/uninst.sh ]] && /usr/local/qcloud/YunJing/uninst.sh || true
[[ -f /usr/local/qcloud/monitor/barad/admin/uninstall.sh ]] && /usr/local/qcloud/monitor/barad/admin/uninstall.sh || true

# 停用 tat_agent
systemctl stop tat_agent 2>/dev/null && systemctl disable tat_agent 2>/dev/null || true
rm -f /etc/systemd/system/tat_agent.service
systemctl daemon-reload && systemctl reset-failed 2>/dev/null || true

# 清理文件和进程
rm -rf /usr/local/sa /usr/local/agenttools /usr/local/qcloud

process=(sap100 secu-tcs-agent sgagent64 barad_agent agent agentPlugInD pvdriver)
for i in "${process[@]}"; do
    for pid in $(pgrep -f "$i" 2>/dev/null); do
        kill -9 "$pid" 2>/dev/null || true
    done
done

chkconfig --level 35 postfix off 2>/dev/null || true
service postfix stop 2>/dev/null || true
echo '' > /var/spool/cron/root 2>/dev/null || true
echo '#!/bin/bash' > /etc/rc.local

log_info "✅ 腾讯云监控卸载完成"
