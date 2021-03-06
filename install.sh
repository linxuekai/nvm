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

nvm_conf_profile=/etc/profile.d/nvm-conf-profile.sh

#  路径设置添加到 /etc/profile.d
[ -r $nvm_conf_profile ] ||
  cp $(dirname $(readlink -f $0))/nvm-conf-profile.sh $nvm_conf_profile
exit_if_err "创建 $nvm_conf_profile 失败"

# 支持 zsh
etc_zshrc=/etc/zsh/zshrc
if [ -r $etc_zshrc ]; then
  source_cmd='source /etc/profile.d/nvm-conf-profile.sh'
  grep -q "^$source_cmd$" $etc_zshrc ||
    echo $source_cmd >>$etc_zshrc
fi

ln -s $(dirname $(readlink -f $0))/nvm.sh /usr/local/bin/nvm && {
  echo 'nvm 安装成功，请参考以下方法使用：'
  nvm usage
  echo '由于修改了默认PATH，访问 npm 全局包将在以下操作时生效：'
  echo '1. 如果你是ssh连接，请退出后重连；'
  echo '2. 如果你是桌面端，请注销后重登。'
}
