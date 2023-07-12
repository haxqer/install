#!/bin/bash

wget http://update.aegis.aliyun.com/download/uninstall.sh && chmod +x uninstall.sh &&./uninstall.sh
wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh && chmod +x quartz_uninstall.sh && ./quartz_uninstall.sh

rm -r /usr/local/aegis
systemctl disable aliyun.service
rm /usr/sbin/aliyun-service
rm /usr/sbin/aliyun-service.backup
rm /usr/sbin/aliyun_installer
rm /etc/systemd/system/aliyun.service
rm /lib/systemd/system/aliyun.service
rm uninstall.sh quartz_uninstall.sh

export ARCH=amd64
/usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall
/usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop
/usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} stop && \
/usr/local/cloudmonitor/CmsGoAgent.linux-${ARCH} uninstall && \
rm -rf /usr/local/cloudmonitor

/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh stop
/usr/local/cloudmonitor/wrapper/bin/cloudmonitor.sh remove && \
rm -rf /usr/local/cloudmonitor

systemctl stop aliyun && systemctl disable aliyun
systemctl stop aegis && systemctl disable aegis
rm -f /system.slice/aegis.service
systemctl daemon-reload && systemctl reset-failed