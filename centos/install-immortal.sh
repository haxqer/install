#!/bin/bash

curl -s https://packagecloud.io/install/repositories/immortal/immortal/script.rpm.sh | sudo bash && \
  yum install immortal -y

