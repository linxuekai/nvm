#!/bin/bash

# 需要权限
[ "root" = "$(whoami)" ] || {
  echo '非 root 请使用 sudo 运行'
  exit 1
}

ln -s $(dirname $(readlink -f $0))/nvm.sh /usr/local/bin/nvm &&
  echo 'nvm 安装成功，请参考以下方法使用：'
nvm usage
