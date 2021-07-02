#/bin/bash

# @func - 封装出错返回
# @param $1 - 错误提示
exit_if_err() {
    RET=$?
    [ $RET -eq 0 ] || {
        echo $1
        exit $RET
    }
    unset RET
}

# @func - 需要权限时检查如果不是 root 运行就退出
check_permission() {
    [ "root" = "$(whoami)" ]
    exit_if_err '非 root 请使用 sudo 运行'
}

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
