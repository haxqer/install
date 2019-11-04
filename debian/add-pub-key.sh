#!/bin/bash

pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2xwdBPeyJaJgddhu4cmYD2/s70Q/WeOrWqzEre3R90FTtjZtsBkx62oTiX+10gL/ZS3P4HGdkiHty2yV0SLJtpaP+ZCVu1aJyIoZrjHGAZNsJGD6ocPlnY47pmZERHxEebpQrJYzdUye2T7wIRZ+kkjHAcOkIclHQPanf/rVjpvQJ1yqaKS9zGHnEDFaptvHbDJQNS2NhhM0/NgLHHLxpIx4uHj6wMRdbkisiSyQhkDRne2SNE+TBV/w98vQIOff0n2wMlo8JV/kRdRBtBq35FOl0CiihNe5bhUlQWvqPgDqyUTJ9CARIk3+lwJjDPS5gB4Ba3N2j0HTYqW9XEN1r haxqer"

mkdir -p ~/.ssh
echo ${pub_key} >> ~/.ssh/authorized_keys


