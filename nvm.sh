#/bin/bash

# @func - 封装出错返回
# @param $1 - 错误提示
exit_if_err () {
    RET=$?
    [ $RET -eq 0 ] || {
        echo $1
        exit $RET
    }
    unset RET
}

# @func - 需要权限时检查如果不是 root 运行就退出
check_permission () {
    [ "root" = "$USER" ]
    exit_if_err '非 root请使用 sudo 运行'
}

# 定义变量
node_link_path="/usr/local/nodejs"
node_bin_path="$node_link_path/bin"
node_versions_dir="/opt/node-versions"
npm_global_dir="$node_versions_dir/npm_global_modules"
npm="$node_bin_path/npm"
add_node_path="/etc/profile.d/add_node_path.sh"

check_init () {
    [ -r "$add_node_path" ] &&\
    [ -L "$node_link_path" ] &&\
    [ -d "$npm_global_dir" ] &&\
    [ -x $npm ] &&\
    [ "`$npm config get prefix`" = "$npm_global_dir" ] ||\
    {
        echo "未初始化，先运行 nvm init"
        return 1
    }
}

list () {
    [ -x $node_bin_path/node ] && v_current=`$node_bin_path/node --version`
	versions=`ls $node_versions_dir | grep -oP 'v(\d+\.?)+'`
	for version in $versions;
	do
		[ "$version" = "$v_current" ] && echo "* $version" || echo "  $version"
	done
}

check_version_input () {
    [ `echo $1 | grep -P '^v(\d+\.){2}\d+$' | wc -l` -eq 1 ]
    exit_if_err '版本号不正确 匹配 v主版本号.次版本号.修订号'
}

usage () {
    echo "usage: nvm [ls | use | init | install] [version]"
}

use () {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1

    v_use=`list | grep $1`

    # 没有找到版本号则退出
    [ -n "$v_use" ]
    exit_if_err '未找到该版本号'

    # 找到的版本号正在使用中则退出
    [ -z "`echo $v_use | grep -P "^\*"`" ]
    exit_if_err "正在使用 $v_use"

    # 可以切换的版本号
    # 删除原有软连接并重新创建
    [ -L "$node_link_path" ] && rm $node_link_path
    v_dir_name=`ls $node_versions_dir | grep $v_use`
    ln -s $node_versions_dir/$v_dir_name $node_link_path
    exit_if_err '重新创建软连接失败'
}

init () {
    # 检查权限
    check_permission

    # 创建 npm 全局包文件夹
    [ -d "$npm_global_dir" ] || {
        mkdir -p $npm_global_dir
        exit_if_err "创建 $npm_global_dir 失败"
    }
    
    # 如果当前已经安装 node 版本
    # 添加 node, npm 路径到 PATH
    # node_path=`which node | awk -F bin/node '{print $1}'`
    [ -x $npm ] && {
        PATH="$PATH:$node_bin_path"
        $npm config set prefix $npm_global_dir && {
            [ -r "$add_node_path" ] ||\
            echo "PATH=$npm_global_dir/bin:$node_bin_path:\$PATH" >> $add_node_path &&\
            . $add_node_path
            exit_if_err  "创建并加载 $add_node_path 失败"
        }
    }
    
    exit_if_err "未安装 node.js, 先 nvm install {version}"
}

install () {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1
    
    # 机器表示，不同机器需要不同的安装包
    m_flag=`uname -m`
    [ "$m_flag" = "x86_64" ] && m_flag='x64'

    # 下载并放到 tmp 目录
    url="https://nodejs.org/dist/$1/node-$1-linux-$m_flag.tar.xz"
    wget $url -q --show-progress -O /tmp/node-$1.tar.xz
    exit_if_err "下载 $url 失败"

    # 解压放到多版本文件夹
    tar -xJf /tmp/node-$1.tar.xz -C $node_versions_dir || {
        RET=$0

        echo -e "\n安装失败，下载的 node 安装包不完整，请重试。"
        
        # 清理垃圾
        bad_dir_name=`ls $node_versions_dir | grep $1`
        rm -r $node_versions_dir/$bad_dir_name
        rm /tmp/node-$1.tar.xz

        exit $RET
    }

    # 解压完了调用 use 使可以使用
    use $1
    exit_if_err "use 版本 $1 失败"

    # 第一次安装版本时需要 init 并重启终端
    check_init || {
        init &&\
        echo "node $1 安装成功，这是你的第一次安装 node，需要重新启动终端才能生效。"
    }
}

remove () {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1

    [ -x $node_bin_path/node ] && v_current=`$node_bin_path/node --version`
    exit_if_err '未安装 node 版本'

    [ "$1" != "$v_current" ]
    exit_if_err '不能删除当前正在使用的版本'

    rm -r $node_versions_dir/*$1*
}

case "$1" in
init)
    init
    ;;
ls | list)
    check_init &&\
    list
    ;;
use)
    check_init &&\
    use $2
    ;;
i | install)
    install $2
    ;;
r | rm | remove)
    remove $2
    ;;
*)
    usage
    ;;
esac
