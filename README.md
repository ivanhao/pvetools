# pvetools
proxmox ve tools script(debian9+ can use it).Including `email`, `samba`,` NFS  set zfs max ram`, `nested virtualization` ,`docker `, `pci passthrough` etc.
for english user,please look the end of readme.

这是一个为proxmox ve写的工具脚本（理论上debian9+可以用）。包括`配置邮件`，`samba`，`NFS`，`zfs`，`嵌套虚拟化`，`docker`，`硬盘直通`等功能。



### 安装

##### 中国用户:

###### 方式一：命令行安装

> 需要用root账号来运行

在终端中按行分别执行以下内容：

>pve6.0需要先删除企业源：`rm /etc/apt/sources.list.d/pve-enterprise.list`

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
cd pvetools
./pvetools.sh
```

###### 方式二：下载zip安装

![download](https://upload-images.jianshu.io/upload_images/4171480-49193f4b6f4040fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


- 建议使用方式一来安装，不建议直接下载单sh脚本使用，因为那样更新的功能会无法使用！

- 如果网络无法使用，或命令行使用有困难，可以使用方式二下载zip包拷入系统中使用。

### 卸载
1. 删除下载的pvetools目录


### 运行

在shell中进入pvetools目录，输入
`
./pvetools.sh
`
* 如果提示没有权限，输入`chmod +x ./*.sh`

### 主界面

![main](https://upload-images.jianshu.io/upload_images/4171480-501e3adb625c82fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![main1](https://upload-images.jianshu.io/upload_images/4171480-53fc13764f684c4c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)




根据需要选择对应的选项即可。

#### 配置邮件说明：

只有以下界面需要用tab键选成红框的内容,其他的一律无脑回车即可。

![mail](https://upload-images.jianshu.io/upload_images/4171480-2ee76fb89c0f253e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



#### 如果这个脚本帮到你了，麻烦点一下右上角的star小星星^_^

## qq交流群: 878510703

![qq](http://upload-images.jianshu.io/upload_images/4171480-e0204ead0fb41d5e.jpg)

## 如果觉得好的请捐赠一下^_^
![alipay](https://upload-images.jianshu.io/upload_images/4171480-04c3ebb5c11cfdf9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


感谢捐赠人员！

捐赠列表：

杨惠(来源qq)    


# [版本说明]
##### v2.0.7

发布时间：2019.11.25

new feature:

*   增加安装NFS的功能。

##### [](https://github.com/ivanhao/pvetools#v206-1)v2.0.6

发布时间：2019.11.20

new feature:

*   增加常用工具，此版本增加了局域网扫描
*   修复dockerd启动bug

##### [](https://github.com/ivanhao/pvetools#v205)v2.0.5

发布时间：2019.11.14

new feature:

*   chroot优化,增加对alpine版本的判断，优化速度
*   中文环境下包的下载全改到国内服务器
*   docker配置国内源
*   portainer改用docker pull的方式拉取镜像（之前使用tar包部署，github上下载包太慢）
*   增加chroot后台管理功能，检测chroot的运行
*   删除代码目录中的图片，改成简书图片链接


##### v2.0.4
发布时间：2019.11.06

new feature:
- 增加docker的web界面（portainer)
- 去除隐藏的命令输出，例如apt-get install的输出等。
- chroot优化


##### v2.0.3
发布时间：2019.11.04

new feature:
- 增加qm set映射物理硬盘的功能


##### v2.0.2
发布时间：2019.11.01

new feature:
- 增加chroot功能，默认安装好Alpine
- 增加docker功能，默认安装在Alpine中
- bug修复

##### v2.0.1  
发布时间：2019.10.24

new feature:
- 增加显卡直通的支持


##### v2.0  
发布时间：2019.10.01

new feature:
- 界面修改为whiptail，交互性更好，不需要输入字母来选择
- bug修复

### installation method

###### 1. command line

##### for english user:

Use root accout to run.

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
cd pvetools
./pvetools.sh
```
>If update error,you can remove enterprise source by : `rm /etc/apt/sources.list.d/pve-enterprise.list` and retry.

###### 2. download

![download](https://upload-images.jianshu.io/upload_images/4171480-49193f4b6f4040fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### Interface

![main](https://upload-images.jianshu.io/upload_images/4171480-501e3adb625c82fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![main1](https://upload-images.jianshu.io/upload_images/4171480-0e0920b58ce482d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)




### Uninstall 
1. delete pvetools folder

### Run
cd to pvetools folder,and type:`./pvetools.sh`
* you should `chmod +x pvetools.sh` first.


#### email configration note：

you should choose `Internet Site` below, and keep others default.

![mail](https://upload-images.jianshu.io/upload_images/4171480-2ee76fb89c0f253e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

