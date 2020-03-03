#!/bin/bash

# 需要权限
[ "root" = "$USER" ] || {
  echo '非 root 请使用 sudo 运行'
  exit 1
}

ln $PWD/nvm.sh /usr/local/bin/nvm &&\
nvm usage