#!/bin/bash

# 需要权限
[ "root" = "$USER" ] || {
  echo '非 root 请使用 sudo 运行'
  exit 1
}

rm -r /opt/nvm
rm /usr/local/bin/nvm
rm /etc/profile.d/nvm-conf-profile.sh

if [ -r /etc/zsh/zprofile ]; then
  sed -i --follow-symlinks '/^source \/etc\/profile\.d\/nvm-conf-profile\.sh$/d' /etc/zsh/zprofile
fi

for x in node npm npx; do
  rm /usr/local/bin/$x
done

rm /root/.npmrc
rm /home/*/.npmrc
