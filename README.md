# nvm - Node.js Versions Manager
## Node.js 版本管理器

可能你也用过大名鼎鼎的 `nvm` , 它非常好用，但是觉得它太重了，所以自己简单实现了一个。

作为一个 `Shell` 初学者，我的代码非常有限，如果你觉得不堪入目，请轻喷，一定要怀着爱才、期待的精神来看待才行。这个东西实际上我只考虑自己使用，如果你觉得还能用用那就随便用用，有问题可以讨论，一起学习，手摸手那种也可以。


# Install

首先你要下载我这个仓库
```
git clone https://github.com/linxuekai/nvm.git ~/.nvm
```

然后创建个软连接到你的 PATH 可以找到的地方就行了
```
sudo ln -s ~/.nvm/nvm.sh /usr/local/bin
```


# Usage

版本号 `version` 的输入需要经过校验，规则为 `/^v(\d+\.){2}\d+$/` ( v数字.数字.数字 )

这个脚本提供了以下几个功能 

* ## 安装 node 版本
  ```sh
  sudo nvm install [version]
  ```

* ## 删除 node 版本
  ```sh
  sudo nvm remove [version]
  ```

* ## 查看已安装的 node 版本列表
  ```sh
  sudo nvm install [version]
  ```

* ## 切换使用特定 node 版本
  ```sh
  sudo nvm use [version]
  ```


## Todo

* [ ] 卸载功能
* [ ] 远程版本号获取

<!--
rm /etc/profile.d/add_node_path.sh
rm /opt/node-versions/node* -r    
rm /usr/local/nodejs                                  
rm /tmp/node* -r                  
rm ~/.npmrc
-->
