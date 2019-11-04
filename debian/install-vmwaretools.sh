#!/bin/bash

TOOL_PATH=/tmp/vmwaretools


mkdir /mnt/cdrom
mount /dev/cdrom  /mnt/cdrom
mkdir ${TOOL_PATH}
tar xzf /mnt/cdrom/VMwareTools-*.tar.gz -C ${TOOL_PATH}/ --strip-components 1
${TOOL_PATH}/vmware-install.pl


