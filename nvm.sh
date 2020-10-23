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

# 定义变量
nvm_base=/opt/nvm

node_versions_dir=$nvm_base/node-versions
npm_global_dir=$nvm_base/npm_global
node_current_path=$nvm_base/node-current

node=$node_current_path/bin/node
nvm_conf_profile=/etc/profile.d/nvm-conf-profile.sh

reg_version_name="v(\d{1,2}\.){2}\d{1,2}"

list() {
    [ -x $node ] && v_current=$($node --version)
    versions=$(ls $node_versions_dir 2>/dev/null | grep -oP "$reg_version_name")
    for version in $versions; do
        [ "$version" = "$v_current" ] && echo "* $version" || echo "  $version"
    done
}

check_version_input() {
    echo "$1" | grep -qP "^$reg_version_name$"
    exit_if_err '版本号不正确 匹配 v主版本号.次版本号.修订号'
}

usage() {
    cat <<-EOF
    usage: nvm {action} [version]
    
    actions:
        all             - List all versions in remote server
        list    | ls    - List versions in local machine
        install | i     - Install [version]
        use             - Use [version]
        remove  | r     - Remove [version]

EOF
}

use() {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1

    v_use=$(echo "$(list)" | grep $1)

    # 没有找到版本号则退出
    [ -n "$v_use" ]
    exit_if_err '未找到该版本号'

    # 找到的版本号正在使用中则退出
    echo "$v_use" | grep -qP "^\*" && {
        echo "正在使用 $v_use"
        exit
    }

    # 可以切换的版本号
    # 删除原有软连接并重新创建
    [ -L $node_current_path ] && rm $node_current_path
    v_dir_name=$(ls $node_versions_dir | grep $v_use)
    ln -s $node_versions_dir/$v_dir_name $node_current_path
    exit_if_err '重新创建软连接失败'

    # 重置环境
    init
}

# @func
# 在第一次通过 nvm 安装 node 时进行，
# 使 check_init 检查可以通过
#
init() {
    # /usr/local/bin/[node, npm, npx] 指向 $node_current_path/bin/[x]
    for x in node npm npx; do
        [ /usr/local/bin/$x -ef $node_current_path/bin/$x ] ||
            ln -s $node_current_path/bin/$x /usr/local/bin/$x
        exit_if_err "创建 /usr/local/bin/$x 软连接失败"
    done

    # npm_grobal_dir 文件夹存在
    [ -d $npm_global_dir ] || mkdir -p $npm_global_dir
    exit_if_err "创建 $npm_global_dir 失败"

    #  nvm_conf_profile 存在
    [ -r $nvm_conf_profile ] ||
        cp $(dirname $(readlink -f $0))/nvm-conf-profile.sh $nvm_conf_profile
    exit_if_err "创建 $nvm_conf_profile 失败"

    # 支持 zsh
    etc_zshrc=/etc/zsh/zshrc
    if [ -r $etc_zshrc ]; then
	source_cmd='source /etc/profile.d/nvm-conf-profile.sh'
	grep -q "^$source_cmd$" $etc_zshrc ||
        echo $source_cmd >> $etc_zshrc
    fi

    # /root/.npmrc
    npm c set prefix $npm_global_dir
    # ~/.npmrc
    if [ -n "$SUDO_USER" ]; then
        sudo -u $SUDO_USER npm c set prefix $npm_global_dir
    fi

    # 首次安装 nodejs 提示重登
    if [ $is_install -eq 1 ] && [ $(list | wc -l) -eq 1 ]; then
        echo '由于路径配置只在登录终端中生效， 请重新登录，否则无法通过 PATH 访问到 npm 全局包。'
    fi
}

install() {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1

    # 不能重复安装同一版本
    [ -d $node_versions_dir ] &&
        echo "$(list)" | grep -q $1 && {
        use $1
        exit
    }

    # 机器表示，不同机器需要不同的安装包
    m_flag=$(uname -m)
    [ "$m_flag" = "x86_64" ] && m_flag='x64'
    [ "$m_flag" = "aarch64" ] && m_flag='arm64'

    # 下载并放到 tmp 目录
    url="https://npm.taobao.org/mirrors/node/$1/node-$1-linux-$m_flag.tar.xz"
    wget $url -q --show-progress -O /tmp/node-$1.tar.xz
    exit_if_err "下载 $url 失败"

    # 解压放到多版本文件夹
    [ -d $node_versions_dir ] || mkdir -p $node_versions_dir

    tar -xJf /tmp/node-$1.tar.xz -C $node_versions_dir || {
        RET=$?

        echo -e "\n安装失败，下载的 node 安装包不完整，请重试。"

        # 清理垃圾
        bad_dir_name=$(ls $node_versions_dir | grep $1)
        [ -n "$bad_dir_name" ] && rm -r $node_versions_dir/$bad_dir_name
        rm /tmp/node-$1.tar.xz

        exit $RET
    }

    # 解压完了调用 use 使可以使用
    use $1
}

remove() {
    # 检查权限
    check_permission

    # 检查输入版本号是否正确
    check_version_input $1

    [ -x $node ] && v_current=$($node --version)
    exit_if_err '未安装 node 版本'

    [ "$1" != "$v_current" ]
    exit_if_err '不能删除当前正在使用的版本'

    rm -r $node_versions_dir/*$1*
}

all() {
    curl -s https://npm.taobao.org/mirrors/node/index.tab | awk '/v[1-9][0-9]?\.[0-9]+\.[0-9]+/ {if (($(NF-1) != "-")) {print $1"\tlts:"$(NF-1)} else {print $1}}'
}

case "$1" in
all)
    all
    ;;
ls | list)
    list
    ;;
use)
    use $2
    ;;
i | install)
    is_install=1
    install $2
    ;;
r | rm | remove)
    remove $2
    ;;
*)
    usage
    ;;
esac
