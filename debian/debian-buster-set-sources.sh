#!/bin/bash

echo "

deb http://mirrors.aliyun.com/debian/ buster main
deb-src http://mirrors.aliyun.com/debian/ buster main

deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main

deb http://mirrors.aliyun.com/debian-security/ buster/updates main
deb-src http://mirrors.aliyun.com/debian-security/ buster/updates main

" > /etc/apt/sources.list




