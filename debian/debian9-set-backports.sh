#!/bin/bash

echo "

deb     http://mirrors.aliyun.com/debian stretch main contrib non-free
deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free

deb     http://mirrors.aliyun.com/debian stretch-updates main contrib non-free
deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free

deb     http://mirrors.aliyun.com/debian stretch-backports main contrib
deb-src http://mirrors.aliyun.com/debian stretch-backports main contrib

deb     http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free
deb-src http://mirrors.aliyun.com/debian stretch-proposed-updates main contrib non-free

deb     http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian-security/ stretch/updates main non-free contrib

" > /etc/apt/sources.list




