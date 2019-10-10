# pvetools
proxmox ve tools script(debian9+ can use it).Including install postfix samba and config set zfs max ram, nested virtualization etc.
for english user,please look the end of readme.

这是一个为proxmox ve写的工具脚本（理论上debian9+可以用）。包括配置邮件，samba,zfs，嵌套虚拟化等功能。



### 安装

##### 中国用户:

> 需要用root账号来运行

在终端中按行分别执行以下内容：

>pve6.0需要先删除企业源：`rm /etc/apt/sources.list.d/pve-enterprise.list`

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
cd pvetools
./pvetools.sh
```


### 卸载
1. 删除下载的pvetools目录


### 运行

在shell中进入pvetools目录，输入
`
./pvetools.sh
`
* 如果提示没有权限，输入`chmod +x ./*.sh`

### 主界面

![main](./main.png)
![main](./main1.png)

根据需要选择对应的选项即可。

#### 配置邮件说明：

只有以下界面需要用tab键选成红框的内容,其他的一律无脑回车即可。
![mail](./mail.png)


#### 如果这个脚本帮到你了，麻烦点一下右上角的star小星星^_^

## 如果觉得好的请捐赠一下^_^
![pay](./pay.jpg)

### install

##### for english user:

```
export LC_ALL=en_US.UTF-8
apt update && apt -y install git && git clone https://github.com/ivanhao/pvetools.git
cd pvetools
./pvetools.sh
```

### Uninstall 
1. delete pvetools folder



