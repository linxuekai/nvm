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
