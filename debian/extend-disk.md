# extend disk

硬盘扩容

## 

`fdisk -u /dev/sda`
```shell
# delete partition
d

# create partition
n

# Enter && Yes

# select type
t

# 83 linux
83

# write
w
```


`partx /dev/sda && resize2fs /dev/sda1`

检查

`df -lh`

`fdisk -l`
