# extend disk

硬盘扩容

## 

`fdisk -u /dev/sda`
```shell
# delete partition
d
2

# create partition
n
p
2

# Enter && Yes

# select type
t
2
# 8e linux lvm
8e

# write
w
```

reboot: `reboot`

`partx -u /dev/sda && pvresize /dev/sda2 && lvextend -r centos/root /dev/sda2`

检查

`df -lh`

`fdisk -l`
