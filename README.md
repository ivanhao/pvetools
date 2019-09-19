# pvetools
proxmox ve tools script(debian9+ can use it).Including install postfix samba and config set zfs max ram, nested virtualization etc.
for english user,please look the end of readme.
这是一个为proxmox ve写的工具脚本（理论上debian9+可以用）。包括配置邮件，samba,zfs，嵌套虚拟化等功能。


### 安装
#####中国地区用户:
```
sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
cp /etc/apt/sources.list /etc/apt/sources.list.init
cp /etc/apt/sources.list.d/pve-no-sub.list /etc/apt/sources.list.d/pve-no-sub.list.init
cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.init
cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.init
echo "deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list
apt update
apt -y install git 
git clone https://github.com/ivanhao/pvetools.git
cd pvetools && ./pvetools.sh
&&
```
###主界面



### install
#####for english user:
```
apt update
apt -y install git 
git clone https://github.com/ivanhao/pvetools.git
cd pvetools && ./pvetools.sh
&&
```



