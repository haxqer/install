#!/bin/bash

crontab -r

/usr/local/qcloud/stargate/admin/uninstall.sh
/usr/local/qcloud/YunJing/uninst.sh
/usr/local/qcloud/monitor/barad/admin/uninstall.sh

systemctl stop tat_agent && systemctl disable tat_agent
rm -f /etc/systemd/system/tat_agent.service
systemctl daemon-reload && systemctl reset-failed

rm -rf /usr/local/sa
rm -rf /usr/local/agenttools
rm -rf /usr/local/qcloud
process=(sap100 secu-tcs-agent sgagent64 barad_agent agent agentPlugInD pvdriver )
for i in ${process[@]}
do
for A in $(ps aux |grep $i |grep -v grep |awk '{print $2}')
do
kill -9 $A
done
done
chkconfig --level 35 postfix off
service postfix stop
echo ''>/var/spool/cron/root
echo '#!/bin/bash' >/etc/rc.local
