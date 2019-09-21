# pvetools
proxmox ve tools script(debian9+ can use it).Including install postfix samba and config set zfs max ram, nested virtualization etc.
for english user,please look the end of readme.

这是一个为proxmox ve写的工具脚本（理论上debian9+可以用）。包括配置邮件，samba,zfs，嵌套虚拟化等功能。


### 安装

##### 中国用户:

> 需要用root账号来运行

把下面整段复制粘贴到终端中回车即可。
```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git \
&& cd pvetools && ln -s `pwd`/pvetools.sh /usr/bin/pvetools && pvetools
```
### 卸载
1. 运行
```
rm /usr/bin/pvetools
```
2. 删除下载的pvetools目录


### 运行

在shell中输入
`
pvetools
`

### 主界面

![main](./main.png)
根据需要选择对应的选项即可。

#### 配置邮件说明：

只有以下界面需要用tab键选成红框的内容,其他的一律无脑回车即可。
![mail](./mail.png)

#### 无脑方式说明：

无脑方式基本不需要你输入内容，除了配置你的邮件地址，邮箱要按上面配置邮件说明中的"Internet Site", 
其他的一律无脑回车即可。
其他的一律无脑回车即可。
其他的一律无脑回车即可。

#### 如果这个脚本帮到你了，麻烦点一下右上角的star小星星^_^

## 如果觉得好的请捐赠一下，自愿捐赠五毛一块的你也没啥损失，我也不会发大财，但是是对我的一种鼓励^_^
![pay](./pay.jpg)

### install

##### for english user:

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git \
&& cd pvetools && ln -s `pwd`/pvetools.sh /usr/bin/pvetools && pvetools
```

### Uninstall 
1. Run:
```
rm /usr/bin/pvetools
```
2. delete pvetools folder



