#!/bin/bash
#修改debian的镜像源地址：

echo "deb https://mirrors.ustc.edu.cn/debian/ stretch main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ stretch main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ stretch-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ stretch-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ stretch-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ stretch-backports main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ stretch/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ stretch/updates main contrib non-free" > /etc/apt/sources.list
#修改pve 5.x 更新源地址为 no subscription，不使用企业更新源
echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
#关闭pve 5.x企业更新源
sed -i.bak 's|deb https://enterprise.proxmox.com/debian stretch pve-enterprise|# deb https://enterprise.proxmox.com/debian stretch pve-enterprise|' /etc/apt/sources.list.d/pve-enterprise.list
#修改 ceph镜像更新源
echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous stretch main" > /etc/apt/sources.list.d/ceph.list

#apt-get update
#apt-get -y install git vim net-tools cpufrequtils samba
if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
  echo "export LC_ALL=en_US.UTF-8" >> /etc/profile
fi
if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
  echo "alias ll='ls -alh'" >> /etc/profile
fi
source /etc/profile
#set max zfs ram
if [ ! -f /etc/modprobe.d/zfs.conf ] || [ `grep "zfs_arc_max" /etc/modprobe.d/zfs.conf|wc -l` = 0 ];then
  echo "options zfs zfs_arc_max=4294967296">/etc/modprobe.d/zfs.conf
  update-initramfs -u
fi

#config samba
if [ `grep samba /etc/group|wc -l` = 0 ];then
  groupadd samba
  useradd -g samba -M -s /sbin/nologin admin
  echo "Please input admin's password:"
  passwd admin
  echo "Please input samba user's password:"
  smbpasswd -a admin
  service smbd restart
fi


#config vim
if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ];then
cat << EOF > /root/.vimrc
set number
set showcmd
set incsearch
set expandtab
set showcmd
set history=400
set autoread
set ffs=unix,mac,dos
set hlsearch
set shiftwidth=2
set wrap
set ai
set si
set cindent
set termencoding=unix
set tabstop=2
set nocompatible
set showmatch
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileformats=unix
set ttyfast
syntax on
set imcmdline
set previewwindow
set showfulltag
set cursorline
set ruler
color ron 
autocmd InsertEnter * se cul  
set ruler 
set showcmd 
set laststatus=2    
set tabstop=2     
set softtabstop=4  
inoremap qq <esc>  
autocmd BufWritePost \$MYVIMRC source \$MYVIMRCi
EOF
fi

#set hard drivers to spindown
if [ ! -f /root/hdspindown/spindownall ];then
  cd /root
  git clone https://github.com/ivanhao/hdspindown.git
  cd hdspindown
  chmod +x *.sh
  #./spindownall
  if [ `grep "spindownall" /etc/crontab|wc -l` = 0 ];then
cat << EOF >> /etc/crontab
*/10 * * * * root /root/hdspindown/spindownall
EOF
    service cron reload
  fi
fi

#setup for cpufreq
if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
  sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub 
  update-grub
fi
if [ ! -f /etc/default/cpufrequtils ];then
cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="powersave"
MAX_SPEED="1600000"
MIN_SPEED="1600000"
EOF
  echo -e " \033[31m cpufrequtils need to reboot to apply! Please reboot.  \033[0m"
fi

#set rpool to list snapshots
if [ `zpool get listsnapshots|grep rpool|awk '{print $3}'` = "off" ];then
  zpool set listsnapshots=on rpool
fi

echo "Init Done! Enjoy!"
