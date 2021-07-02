#!/bin/bash

. ./funcs.sh

# @func - 需要权限时检查如果不是 root 运行就退出
check_permission

rm -r /opt/nvm
rm /usr/local/bin/nvm
rm /etc/profile.d/nvm-conf-profile.sh

etc_zshrc=/etc/zsh/zshrc
if [ -r $etc_zshrc ]; then
  sed -i --follow-symlinks '/^source \/etc\/profile\.d\/nvm-conf-profile\.sh$/d' $etc_zshrc
fi

for x in node npm npx; do
  rm /usr/local/bin/$x
done
