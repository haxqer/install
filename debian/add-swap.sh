#!/bin/bash

cd /var
dd if=/dev/zero of=swapfile bs=1024 count=1097152
mkswap swapfile
swapon swapfile
echo '\n/var/swapfile        swap                 swap       defaults              0 0' >> /etc/fstab
