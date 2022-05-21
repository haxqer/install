#!/bin/bash

echo "

deb     http://mirrors.ustc.edu.cn/debian stretch main contrib non-free
deb-src http://mirrors.ustc.edu.cn/debian stretch main contrib non-free

deb     http://mirrors.ustc.edu.cn/debian stretch-updates main contrib non-free
deb-src http://mirrors.ustc.edu.cn/debian stretch-updates main contrib non-free

deb     http://mirrors.ustc.edu.cn/debian stretch-backports main contrib
deb-src http://mirrors.ustc.edu.cn/debian stretch-backports main contrib

deb     http://mirrors.ustc.edu.cn/debian stretch-proposed-updates main contrib non-free
deb-src http://mirrors.ustc.edu.cn/debian stretch-proposed-updates main contrib non-free

deb     http://mirrors.ustc.edu.cn/debian-security/ stretch/updates main non-free contrib
deb-src http://mirrors.ustc.edu.cn/debian-security/ stretch/updates main non-free contrib

" > /etc/apt/sources.list




