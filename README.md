![logo](https://upload-images.jianshu.io/upload_images/4171480-4fc23dfbe28b491a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# pvetools
proxmox ve tools script(debian9+ can use it).Including `email`, `samba`,` NFS  set zfs max ram`, `nested virtualization` ,`docker `, `pci passthrough` etc.
for english user,please look the end of readme.

这是一个为proxmox ve写的工具脚本（理论上debian9+可以用）。包括`配置邮件`，`samba`，`NFS`，`zfs`，`嵌套虚拟化`，`docker`，`硬盘直通`等功能。



### 安装

##### 中国用户:

###### 方式一：命令行安装

> 需要用root账号来运行

在终端中按行分别执行以下内容：

>强烈建议先删除企业源：`rm /etc/apt/sources.list.d/pve-enterprise.list`

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
cd pvetools
./pvetools.sh
```

### 一键无脑安装:

```
echo "nameserver  8.8.8.8" >> /etc/resolv.conf && rm -rf pvetools && rm -rf /etc/apt/sources.list.d/pve-enterprise.list && export LC_ALL=en_US.UTF-8 && apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git && echo "cd /root/pvetools && ./pvetools.sh" > pvetools/pvetools && chmod +x pvetools/pvetools* && ln -s /root/pvetools/pvetools /usr/local/bin/pvetools && pvetools
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

蓝蓝的天空（来源qq）

久别重逢（来源qq）

小呀嘛小Kiwi（来源qq)

*兴乐（来源支付宝）

孤独的根号三 （来源qq）

我心依旧丶(来源qq)

*俊磊（来源支付宝）

*家鑫（来源支付宝）

*小虎（来源支付宝）

*杭（来源支付宝）

*伟（来源支付宝）

*棘（来源支付宝）

zm （来源qq）

*阳 (来源支付宝)

**鑫 (来源支付宝)

**尧 (来源支付宝)

*潋 (来源支付宝)

**泽 (来源支付宝)

**涛 (来源支付宝)

*韬 (来源支付宝)

**旭 (来源支付宝)

**明 (来源支付宝)

**锐 (来源支付宝)

# [版本说明]

##### v2.4.0

发布时间：2024.02.08

new feature:

* 修复有些功能还原配置时出现问题，比如温度显示，去除订阅等

* 修复配置apt国内源、安装配置VIM可导致原配置文件被覆盖

##### v2.3.9

发布时间：2023.10.19

new feature:

* 增加pve8的支持

* 优化英文语言的显示

##### v2.3.6

发布时间：2023.02.16

new feature:

* 合并网友“for5million”提交的关于pci直通的修复。

##### v2.3.5

发布时间：2022.09.14

new feature:

* 修复docker无法安装的问题，更换alpine的安装源。

##### v2.3.2

发布时间：2022.07.14

new feature:

* 温度显示上方增加CPU频率显示。
* add cpu frequency display.


##### v2.3.1

发布时间：2022.07.13

* 调整省电模式powersave为conservative。
* change cpufrequtils from 'powersave' to 'conservative'。


##### v2.3.0

发布时间：2022.05.30

new feature:

* 修复pve7（debian 11)后security更新源地址格式变动的影响。
* fix pve7 (debian 11) security source address.

* 添加pve7以上版本配置硬件直通里的参数`iommu=pt pcie_acs_override=downstream`
* add pve7　grub config `iommu=pt pcie_acs_override=downstream`

* 删除默认.vimrc中重复的`set termencoding=unix`
* delete .vimrc duplicate termencoding setting `set termencoding=unix`

* 增加去除订阅提示的修复
* add reinstall proxmox-widget-toolkit to fix remove subscription failure.

##### v2.2.9

发布时间：2022.05.29

new feature:

* 增加常用工具下的自动扩展ROOT分区可用空间，比如有些用户使用dd等方式克隆系统盘，更换大硬盘还原镜像后可以一键扩展分区
* add auto expand / partition size.

##### v2.2.8

发布时间：2021.10.26

new feature:

* 优化pve7去订阅提示的判断和处理。
* fix pve7 subscription note.

##### v2.2.7

发布时间：2021.10.14

new feature:

* 在常用的工具下添加pve界面黑暗模式
* add proxmox ve darkmode interface to manyTools.

##### v2.2.6

发布时间：2021.09.09

new feature:

* 添加pve7的支持。
* add proxmox ve 7.x support.

##### v2.2.5

发布时间：2020.12.16

new feature:

* 优化pve升级后温度安装提示判断逻辑。
* update sensors data install.

##### v2.2.4

发布时间：2020.12.14

new feature:

* 修复温度显示界面高度自适应。
* fix sensors display interface.

##### v2.2.3

发布时间：2020.12.09

new feature:

* 增加对/etc/pve/qemu-server下的conf文件自动备份功能，可以选择备份路径和保留备份个数，建议备份到系统分区以外的虚拟机数据盘中，这样重装系统后方便直接恢复


##### v2.2.2

发布时间：2020.11.30

new feature:

* 根据群友`嗨 我是奶酪`的建议，添加pve 更新源地址为非订阅更新源



##### v2.2.0

发布时间：2020.08.17

new feature:

* 增加USB设备做为系统盘的优化，在'常用工具'下。

##### v2.1.9

发布时间：2020.07.15

new feature:

* 增加N卡vbios的提示功能，在'常用工具'下。

##### v2.1.8

发布时间：2020.07.14

new feature:

* 修复cpu省电，还原配置无法恢复频率的问题。


##### v2.1.7

发布时间：2020.05.19

new feature:

* 优化cpu省电提示，处理卸载后再次运行不安装cpufrequtils的问题。

##### v2.1.5

发布时间：2020.03.28

new feature:

* 解决docker重启不能自动启动的问题。

##### v2.1.4

发布时间：2020.02.21

new feature:

* 常用工具中增加释放内存、speedtest、bbr\bbr+、v2ray功能

##### v2.1.3

发布时间：2019.12.24

new feature:

* 优化samba回收站配置,在设置共享文件夹时自动提示是否开启；可以单独增加和取消某个共享文件夹的回收站；
* 优化web界面温度显示功能

##### v2.1.2

发布时间：2019.12.18

new feature:

* 增加samba回收站配置

##### v2.1.1

发布时间：2019.12.16

new feature:

* 常用工具中增加dns配置

##### v2.1.0

发布时间：2019.12.09

new feature:

* 增加在pve中直接安装omv( [omvInPve](https://github.com/ivanhao/omvinpve))。

##### v2.0.9

发布时间：2019.12.04

new feature:

* 增加samba共享文件夹权限自动配置，不再需要手工配置权限；同时删除共享文件夹会自动还原原来的用户组权限。
  建议之前已使用的用户可以先删除旧的共享文件夹，手工恢复权限后，再用工具配置添加。

##### v2.0.8

发布时间：2019.11.28

new feature:

*   增加chroot自定义安装路径的功能。
*   增加chroot docker迁移的功能。
 [wiki](https://github.com/ivanhao/pvetools/wiki/m--1-%E9%85%8D%E7%BD%AEdocker-web%E7%95%8C%E9%9D%A2)

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

