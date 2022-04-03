#!/bin/bash

tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://hub-mirror.c.163.com/",
        "https://docker.mirrors.ustc.edu.cn/",
        "https://mirror.baidubce.com"
    ]
}
EOF

systemctl daemon-reload
systemctl restart docker


