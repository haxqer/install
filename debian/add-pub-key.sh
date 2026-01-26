#!/bin/bash

pub_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwzgqGNzBlRkdbFdBYIIw7EVRcycpVnOnfQ37YgSZh+ haxqer"

mkdir -p ~/.ssh
echo ${pub_key} >> ~/.ssh/authorized_keys



