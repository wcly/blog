### nvm
用于管理多个`node`版本的工具。

安装：

1. 点击 [下载地址](https://github.com/coreybutler/nvm-windows/releases) 进入nvm下载页面；
2. 选择最新版本，进去之后选择`nvm-setup.zip`安装版，下载之后解压安装即可；
3. 遇到`Set Node.js Symlink`步骤指的是设置nodeJS的快捷方式存放的目录；
4. 如果本地有安装过node，会提示是否加入nvm版本管理选择确定即可。

常用命令：

命令 | 含义
---|---
`nvm` | 查看所有命令
`nvm list` | 查看现在使用的node版本
`nvm list available` | 查看node所有可安装版本
`nvm node_mirror` node镜像地址 | 设置node镜像地址
`nvm npm_mirror` npm镜像地址 | 设置npm镜像地址
`nvm install` node版本号 | 安装指定版本node
`nvm use` node版本号 | 使用指定版本node
`nvm uninsstall` node版本号 | 卸载指定版本node

> node淘宝镜像：[https://npm.taobao.org/mirrors/node/](https://npm.taobao.org/mirrors/node/)
>
> npm淘宝镜像：[https://npm.taobao.org/mirrors/npm/](https://npm.taobao.org/mirrors/npm/)
>
> **注意**：切换node版本后，一些全局安装的依赖需要重新安装，不会是用原来的。