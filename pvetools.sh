#!/bin/bash
#############--proxmox tools--##########################
#  Author : 龙天ivan                        
#  Mail: ivanhao1984@qq.com
#  Version: V1.3                          
#  Github: https://github.com/ivanhao/pvetools
########################################################

if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
    if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
        echo "export LC_ALL=en_US.UTF-8" >> /etc/profile
    fi
fi
if [ `grep "alias ll" /etc/profile|wc -l` = 0 ];then
    echo "alias ll='ls -alh'" >> /etc/profile
    echo "alias sn='snapraid'" >> /etc/profile
fi
source /etc/profile
#-----------------functions--start------------------#
#修改debian的镜像源地址：
chSource(){
clear
if [ $L = "en" ];then
    echo -e "\033[31mConfig apt source:\033[0m"
    echo -e "\033[32m[a] \033[31mAutomation mode.\033[0m"
    echo -e "\033[32m[b] \033[31mChange to ustc.edu.cn.\033[0m"
    echo -e "\033[32m[c] \033[31mDisable enterprise.\033[0m"
    echo -e "\033[32m[d] \033[31mUndo Change.\033[0m"
    echo -e "\033[32m[q] \033[31mMain menu.\033[0m"
else
    echo -e "\033[31m配置apt镜像源:\033[0m"
    echo -e "\033[32m[a] \033[31m无脑模式(禁用企业订阅更新源，添加非订阅更新源(ustc.edu.cn),修改ceph镜像更新源)\033[0m"
    echo -e "\033[32m[b] \033[31m更换为国内ustc.edu.cn源\033[0m"
    echo -e "\033[32m[c] \033[31m关闭企业更新源\033[0m"
    echo -e "\033[32m[d] \033[31m还原配置\033[0m"
    echo -e "\033[32m[q] \033[31m返回主菜单\033[0m"
fi
if [ $1 ];then
    x=a
else
    read x 
fi
sver=`cat /etc/debian_version |awk -F"." '{print $1}'`
case "$sver" in
    10 )
        sver="buster"
        ;;
    9 )
        sver="stretch"
        ;;
    8 )
        sver="jessie"
        ;;
    7 )
        sver="wheezy"
        ;;
    6 )
        sver="squeeze"
        ;;
    * )
        sver=""
esac
if [ ! $sver ];then
    echo "您的版本不支持！无法继续。"
    sleep 3
    main
fi
case "$x" in
a | A )
    if [ `grep "ustc.edu.cn" /etc/apt/sources.list|wc -l` = 0 ];then
        #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        cp /etc/apt/sources.list.d/pve-no-sub.list /etc/apt/sources.list.d/pve-no-sub.list.bak
        cp /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/pve-enterprise.list.bak
        cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
        echo "deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list
        #修改pve 5.x更新源地址为非订阅更新源，不使用企业订阅更新源。
        echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
        #关闭pve 5.x企业订阅更新源
        sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
        #修改 ceph镜像更新源
        echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
        apt-get update
        apt-get -y install net-tools
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
    else
        echo -e "\033[31mAlready changed apt source to ustc.edu.cn\033[0m"
        echo -e "\033[31m已经更换apt源为 ustc.edu.cn\033[0m"
    fi
    sleep 2
    if [ ! $1 ];then
        chSource
    fi
    ;;
	b | B  )
    if [ `grep "ustc.edu.cn" /etc/apt/sources.list|wc -l` = 0 ];then
        cp /etc/apt/sources.list /etc/apt/sources.list.bak
        cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
        #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
        echo "deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list
        #修改 ceph镜像更新源
        echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
        apt-get update
        apt-get -y install net-tools
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
    else
        echo -e "\033[31mAlready changed apt source to ustc.edu.cn\033[0m"
        echo -e "\033[31m已经更换apt源为 ustc.edu.cn\033[0m"
    fi
    sleep 2
    chSource
    ;;
c | C  )
    #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
    if [ -f /etc/apt/sources.list.d/pve-no-sub.list ];then
        #修改pve 5.x更新源地址为非订阅更新源，不使用企业订阅更新源
        echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
    else
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
    fi
    if [ `grep "^deb" /etc/apt/sources.list.d/pve-enterprise.list` > 0 ];then
        #关闭pve 5.x企业订阅更新源
        sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
    else
        echo "apt source has been changed successfully!"
        echo "软件源已更换成功！"
    fi
    sleep 2 
    chSource
    ;;
d | D )
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    cp /etc/apt/sources.list.d/pve-no-sub.list.bak /etc/apt/sources.list.d/pve-no-sub.list
    cp /etc/apt/sources.list.d/pve-enterprise.list.bak /etc/apt/sources.list.d/pve-enterprise.list
    cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
    echo "apt source has been changed successfully!"
    echo "软件源已更换成功！"
    sleep 2
    chSource
    ;;
q )
    main
    ;;
* )
    echo "Please comfirm!"
	echo "请重新输入!"
    sleep 1
    chSource
esac
}

chMail(){
#set mailutils to send mail
if [ -f /etc/mailname ];then
    echo -e "\033[31mIt seems you have already configed it before.\033[0m"
    echo -e "\033[31m您好像已经配置过这个了。\033[0m"
    c="ok"
fi
echo -e "\033[31mWill you want to config mailutils & postfix to send notification?(Y/N):\033[0m"
echo -e "\033[31m是否配置mailutils和postfix来发送邮件通知？(Y/N):\033[0m"
if [ $1 ];then
    if [ $c ];then
        x="n"
    else
        x="a"
    fi
else
    read x 
fi
case "$x" in 
    y | yes | a )
        apt -y install mailutils 
        echo -e "\033[31mInput email adress:\033[0m"
        echo -e "\033[31m输入邮箱地址：\033[0m"
        read qqmail
        while [ true ]
        do
            if [ `echo $qqmail|grep '^[a-zA-Z0-9\_\-\.]*\@[A-Za-z\_\-\.]*\.[a-zA-Z\_\-\.]*$'` ];then
                    break
            else
                echo "Wrong email format!!!   input xxxx@qq.com for example.retry:"
                echo "错误的邮箱格式！！！请输入类似xxxx@qq.com并重试："
                read qqmail
            fi
        done
        echo "pve.local" > /etc/mailname
        sed -i -e "/root:/d" /etc/aliases
        echo "root: $qqmail">>/etc/aliases
        dpkg-reconfigure postfix
        service postfix reload
        echo "This is a mail test." |mail -s "mail test" root
        echo -e "\033[31mConfig complete and send test email to you.\033[0m"
        echo -e "\033[31m已经配置好并发送了测试邮件。\033[0m"
        sleep 2
        if [ ! $1 ];then
            main
        fi
        ;;
    n | no )
        ;;
    * )
        echo "Please comfirm!"
		echo "请重新输入!"
        sleep 1
        chMail
esac
}

chZfs(){
#set max zfs ram
if [ ! -f /etc/modprobe.d/zfs.conf ] || [ `grep "zfs_arc_max" /etc/modprobe.d/zfs.conf|wc -l` = 0 ];then
    echo -e "\033[31mset max zfs ram 4(G) or 8(G) etc, just enter number or n?(number/n) \033[0m"
    echo -e "\033[31m设置最大zfs内存（zfs_arc_max),比如4G或8G等, 只需要输入纯数字即可，比如4G输入4?(number/n) \033[0m"
    if [ $1 ];then
        x=a
    else
        read x 
    fi
    case "$x" in
    n | no )
        ;;
    * )
        while [ true ]
        do
            if [[ "$x" =~ ^[1-9]+$ ]]; then
                echo "options zfs zfs_arc_max=$[$x*1024*1024*1024]">/etc/modprobe.d/zfs.conf
                update-initramfs -u
                echo -e "\033[31mConfig complete!you should reboot later.\033[0m"
                echo -e "\033[31m配置完成，一会儿最好重启一下系统。\033[0m"
            else
                echo "Please comfirm!"
				echo "请重新输入!"
                sleep 2
            fi
            #set rpool to list snapshots
            if [ `zpool get listsnapshots|grep rpool|awk '{print $3}'` = "off" ];then
                zpool set listsnapshots=on rpool
            fi
        done
    esac
    #zfs-zed
    echo -e "\033[31mInstall zfs-zed to get email notification of zfs scrub?(Y/n):\033[0m"
    echo -e "\033[31m安装zfs-zed来发送zfs scrub的结果提醒邮件？(Y/n):\033[0m"
    if [ $1 ];then
        zed=a
    else
        read zed
    fi
    case "$zed" in 
    y | yes | a )
        apt -y install zfs-zed 
        echo -e "\033[31mInstall complete!\033[0m"
        echo -e "\033[31m安装zfs-zed成功！\033[0m"
        sleep 2
        ;;
    n | no )
        ;;
    * )
        echo "Please comfirm!"
		echo "请重新输入!"
        sleep 1
    esac
else
    echo -e "\033[31mIt seems you have already configed it before.\033[0m"
    echo -e "\033[31m您好像已经配置过这个了。\033[0m"
    sleep 2
    if [ ! $1 ];then
        main
    fi
fi
}

chSamba(){
#config samba
clear
if [ $L = "en" ];then
    echo -e "\033[31mConfig samba:\033[0m"
    echo -e "\033[32m[a] \033[31mInstall samba and config user.\033[0m"
    echo -e "\033[32m[b] \033[31mAdd folder to share.\033[0m"
    echo -e "\033[32m[C] \033[31mDelete folder to share.\033[0m"
    echo -e "\033[32m[back] \033[31mMain menu.\033[0m"
else
    echo -e "\033[31m配置samba:\033[0m"
    echo -e "\033[32m[a] \033[31m安装配置samba并配置好samba用户\033[0m"
    echo -e "\033[32m[b] \033[31m添加共享文件夹\033[0m"
    echo -e "\033[32m[c] \033[31m删除共享文件夹\033[0m"
    echo -e "\033[32m[q] \033[31m返回主菜单\033[0m"
fi
if [ $1 ];then
    x=a
else
    read x
fi
case "$x" in
a | A )
    if [ `grep samba /etc/group|wc -l` = 0 ];then
        echo -e "\033[31mset samba and admin user for samba?(Y/n):\033[0m"
        echo -e "\033[31m安装samba并配置admin为samba用户？(Y/n):\033[0m"
        if [ $1 ];then
            x=a
        else
            read x
        fi
        case "$x" in 
        y | yes | a )
            apt -y install samba
            groupadd samba
            useradd -g samba -M -s /sbin/nologin admin
            echo -e "\033[31mPlease input samba user admin's password:\033[0m"
            echo -e "\033[31m请输入samba用户admin的密码：\033[0m"
            read m
            while [ true ]
            do
                if [[ ! `echo $m|grep "^[0-9a-zA-Z.-@]*$"` ]] || [[ $m = '^M' ]];then
                    echo -e "\033[31mWrong format!!!   input again:\033[0m"
                    echo -e "\033[31m密码格式不对！！！请重新输入：\033[0m"
                    read m
                else
                    break
                fi
            done
            echo -e "$pass\n$pass"|smbpasswd -a admin
            service smbd restart
            echo -e "\033[31m已成功配置好samba，请记好samba用户admin的密码！\033[0m"
            sleep 3
            ;;
        n | no )
            ;;
        * )
            echo "Please comfirm!"
			echo "请重新输入!"
            sleep 2
        esac
    else
        echo -e "\033[31mAlready configed samba.\033[0m"
        echo -e "\033[31m已配置过samba，没什么可做的!\033[0m"
        sleep 2
    fi
    if [ ! $1 ];then
        chSamba
    fi
    ;;
b | B )
    echo -e "\033[31mExist share folders:\033[0m"
    echo -e "\033[31m已有的共享目录：\033[0m"
    echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
    echo -e "\033[31mInput share folder path:\033[0m"
    echo -e "\033[31m输入共享文件夹的路径:\033[0m"
    read x
    while [ ! -d $x ]
    do
        echo "Path not exist!Input again([q]back):"
        echo "路径不存在，重新输入([q]返回菜单):"
        read x
        case $x in
            q )
                chSamba
                ;;
        esac
    done
    while [ `grep "path \= ${x}$" /etc/samba/smb.conf|wc -l` != 0 ]
    do
        echo "Path exist!Input again([q]back):"
        echo "路径已存在，重新输入([q]返回菜单)："
        read x
        case $x in
            q )
                chSamba
                ;;
        esac
    done
    n=`echo $x|grep -o "[a-zA-Z0-9.-]*$"`
    while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
    do
        echo -e "\033[31mInput share name:\033[0m"
        echo -e "\033[31m输入共享名称：\033[0m"
        read n
        while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
        do
            echo "Name already exist!Input again([q]back):"
            echo "名称已存在，重新输入([q]返回菜单)："
            read n 
            case $n in
                q )
                    chSamba
                    ;;
            esac
        done
    done
    if [ `grep "${x}" /etc/samba/smb.conf|wc -l` = 0 ];then
        cat << EOF >> /etc/samba/smb.conf
[$n]
   comment = All 
   browseable = yes
   path = $x
   guest ok = no
   read only = no
   create mask = 0700
   directory mask = 0700
;  $n end
EOF
        echo "Configed!"
        echo "配置成功！"
        service smbd restart
    else
        echo "Already configed！"
        echo "已经配置过了！"
    fi
    sleep 2
    chSamba
    ;;
c )
    echo -e "\033[31mExist share folders:\033[0m"
    echo -e "\033[31m已有的共享目录：\033[0m"
    echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
    echo -e "\033[31mInput share name:\033[0m"
    echo -e "\033[31m输入共享名称：\033[0m"
    read n
    while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
    do
        echo "Name not exist!Input again([q]back):"
        echo "名称不存在，重新输入([q]返回菜单):"
        read n 
        case $n in
            q )
                chSamba
                ;;
        esac
    done
    if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
        sed "/\[${n}\]/,/${n} end/d" /etc/samba/smb.conf -i 
        echo "Configed!"
        echo "配置成功！"
        service smbd restart
    fi
    sleep 2
    chSamba
    ;;

q )
    main
    ;;
* )
    echo "Please comfirm!"
	echo "请重新输入!"
    sleep 1
    chSamba
esac
}

chVim(){
#config vim
if [ $L = "en" ];then
    echo -e "\033[31mInstall vim and config:\033[0m"
    echo -e "\033[32m[a] \033[31mInstall vim & simply config display.\033[0m"
    echo -e "\033[32m[b] \033[31mInstall vim & config 'vim-for-server'(https://github.com/wklken/vim-for-server).\033[0m"
else
    echo -e "\033[31m安装配置VIM！\033[0m"
    echo -e "\033[32m[a] \033[31m安装VIM并简单配置，如配色行号等，基本是vim原味儿。\033[0m"
    echo -e "\033[32m[b] \033[31m安装VIM并配置'vim-for-server'(https://github.com/wklken/vim-for-server).\033[0m"
fi
if [ $1 ];then
    x=a
else
    read x
fi
case "$x" in 
    a | A  )
        if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ];then
            apt -y install vim
        else
            cp ~/.vimrc ~/.vimrc.bak
        fi
        cat << EOF > ~/.vimrc
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
inoremap fff <esc>h
autocmd BufWritePost \$MYVIMRC source \$MYVIMRCi
EOF
        echo "Install & config complete!"
        echo "安装配置完成!"
        sleep 2
        ;;
    b | B )
        apt -y install curl vim
        cp ~/.vimrc ~/.vimrc_bak
        curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc
        echo "Install & config complete!"
        echo "安装配置完成！"
        sleep 2
        ;;
    * )
        echo "Please comfirm!"
		echo "请重新输入!"
        sleep 1
esac
}

chSpindown(){
#set hard drivers to spindown
if [ ! -f /root/hdspindown/spindownall ];then
    echo -e "\033[31mConfig hard drives to auto pindown?(Y/n):\033[0m"
    echo -e "\033[31m配置硬盘自动休眠？(Y/n):\033[0m"
    if [ $1 ];then
        x=a
    else
        read x
    fi
    case "$x" in 
    y | yes | a )
        apt -y install git
        cd /root
        git clone https://github.com/ivanhao/hdspindown.git
        cd hdspindown
        chmod +x *.sh
        ./spindownall
        if [ `grep "spindownall" /etc/crontab|wc -l` = 0 ];then
            echo -e "\033[31mInput number of .bake to auto spindown:\033[0m"
            echo -e "\033[31m输入硬盘自动休眠的检测时间，周期为分钟，输入5为5分钟:\033[0m"
            read x
            while [ true ]
            do
                if [[ `echo "$x"|grep "[0-9]*"|wc -l` = 0 ]] || [[ $x = "" ]];then
                    echo -e "\033[31m输入格式错误，请重新输入：\033[0m"
                    read x
                else
                    break
                fi
            done
            cat << EOF >> /etc/crontab
*/$x * * * * root /root/hdspindown/spindownall
EOF
            service cron reload
            echo -e "\033[31mConfig every $x .bake to check disks and auto spindown:\033[0m"
            echo -e "\033[31m已为您配置好硬盘每$x分钟自动检测硬盘和休眠。\033[0m"
            sleep 2
        fi
        ;;
    n | no )
        ;;
    * )
        echo "Please comfirm!"
		echo "请重新输入!"
        sleep 1
    esac
else
    echo -e "\033[31mIt seems you have already configed it before.\033[0m"
    echo -e "\033[31m您好像已经配置过这个了。\033[0m"
    sleep 2
    main
fi
}

chCpu(){
#setup for cpufreq
if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
    echo -e "\033[31mInstall cpufrequtils to save power?(Y/n):\033[0m"
    if [ $1 ];then
        x=a
    else
        read x
    fi
    case "$x" in 
    y | yes | a )
        apt -y install cpufrequtils
        sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub 
        update-grub
        if [ ! -f /etc/default/cpufrequtils ];then
            cpufreq-info
            echo "Input MAX_SPEED:"
            echo "输入最大频率：";read x
            while [ true ]
            do
                if [[ `echo "$x"|grep "[0-9]*"|wc -l` = 0 ]] || [[ $x = "" ]];then
                    echo -e "\033[31m输入格式错误,请重新输入：\033[0m"
                    read x
                else
                    break
                fi
            done
            mx=$x
            echo "Input MIN_SPEED:"
            echo "输入最小频率：";read x
            while [ true ]
            do
                if [[ `echo "$x"|grep "[0-9]*"|wc -l` = 0 ]] || [[ $x = "" ]];then
                    echo -e "\033[31m输入格式错误，请重新输入：\033[0m"
                    read x
                else
                    break
                fi
            done
            mi=$x
            cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="powersave"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
            echo -e " \033[31m cpufrequtils need to reboot to apply! Please reboot.  \033[0m"
            echo -e " \033[31m cpufrequtils 安装好后需要重启系统，请稍后重启。\033[0m"
            sleep 2
        fi
        ;;
    n | no )
        ;;
    * )
        echo "Please confirm!"
        sleep 1
    esac
else
    echo -e "\033[31mIt seems you have already configed it before.\033[0m"
    echo -e "\033[31m您好像已经配置过这个了。\033[0m"
    sleep 2
fi
}

chSubs(){
    clear
    case $L in
        en )
            echo -e "\033[31mRemove subscribe notice.\033[0m"
            ;;
        zh )
            echo -e "\033[31m去除订阅提示\033[0m"
            ;;
    esac
    if [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 1 ];then
        sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
        echo "Done!!"
        echo "去除成功！"
    else
        echo "You already removed." 
        echo "已经去除过了，不需要再次去除。"
   fi
    sleep 2
}
chSmartd(){
  hds=`lsblk|grep "^[s,h]d[a-z]"|awk '{print $1}'`
}

chNestedV(){
    clear
    case $L in
        en )
            echo -e "\033[32m[a] \033[31mEnable nested\033[0m"
            echo -e "\033[32m[b] \033[31mSet vm to nested.\033[0m"
            echo -e "\033[32m[q] \033[31mback to main menu.\033[0m"
            ;;
        zh )
            echo -e "\033[32m[a] \033[31m开启嵌套虚拟化\033[0m"
            echo -e "\033[32m[b] \033[31m开启某个虚拟机的嵌套虚拟化\033[0m"
            echo -e "\033[32m[q] \033[31m返回主菜单\033[0m"
            ;;
    esac
    if [ $1 ];then
        x=a
    else
        read x
    fi
    case "$x" in
        a )
            echo -e "\033[31mAre you sure to enable Nested? (Y/n):\033[0m"
            echo -e "\033[31m确定要开启嵌套虚拟化吗？(Y/n):\033[0m"
            read y
            case "$y" in
                y | Y )
                if [ `cat /sys/module/kvm_intel/parameters/nested` = 'N' ];then
                    for i in `qm list|awk 'NR>1{print $1}'`;do
                        qm stop $i
                    done
                    modprobe -r kvm_intel  
                    modprobe kvm_intel nested=1
                    if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                        echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf
                        echo "Nested ok."
                        echo "您已经开启嵌套虚拟化。"
                    else
                        echo "Your system can not open nested."
                        echo "您的系统不支持嵌套虚拟化。"
                    fi
                else
                    echo "You already enabled nested virtualization."
                    echo "您已经开启过嵌套虚拟化。"
                fi
                sleep 2
                if [ ! $1 ];then
                    chNestedV
                fi
                ;;
                * )
                chNestedV
            esac
            ;;
        b )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                echo "Nested ok."
                if [ `qm list|wc -l` = 0 ];then
                    echo "You have no vm."
                    echo "您还没有虚拟机。"
                else
                    qm list
                    echo -e "\033[31mPlease input your vmid:\033[0m"
                    read vmid
                    if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                        args=`qm showcmd 104|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                        echo  $args",+vmx" >> /etc/pve/qemu-server/$vmid.conf
                        echo "Nested OK.Please reboot your vm."
                        echo "您的虚拟机已经开启嵌套虚拟化支持。重启虚拟机后生效。"
                    else
                        echo "You already seted.Nothing to do."
                        echo "您的虚拟机已经开启过嵌套虚拟化支持。"
                    fi
                fi
                sleep 2
                chNestedV
            else
                echo "Your system can not open nested."
                echo "您的系统不支持嵌套虚拟化。"
                sleep 2
                chNestedV
            fi
            ;;
        q )
            main
            ;;
        * )
            chNestedV
    esac
}
chSensors(){
#安装lm-sensors并配置在界面上显示
#for i in `sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`;do modprobe $i;done
clear
echo -e "\033[31m安装配置lm-sensors并配置web界面显示温度。\033[0m"
echo -e "\033[31mInstall lm-sensors and config web interface to display sensors data.\033[0m"
case $L in
    en )
        echo -e "\033[32m[a] \033[31mInstall\033[0m"
        echo -e "\033[32m[b] \033[31mUninstall\033[0m"
        echo -e "\033[32m[q] \033[31mback to main menu.\033[0m"
        ;;
    zh )
        echo -e "\033[32m[a] \033[31m安装\033[0m"
        echo -e "\033[32m[b] \033[31m卸载\033[0m"
        echo -e "\033[32m[q] \033[31m返回主菜单\033[0m"
        ;;
esac
if [ $1 ];then
    x=a
else
    read x
fi
case "$x" in
    a )
    js='/usr/share/pve-manager/js/pvemanagerlib.js'
    pm='/usr/share/perl5/PVE/API2/Nodes.pm'
    sh='/usr/bin/s.sh'
    ppv=`/usr/bin/pveversion`
    OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
    ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
    bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
    pve=$OS$ver
    if [[ "$OS" != "pve" ]];then
        echo "您的系统不是Proxmox VE, 无法安装!"
        echo "Your OS is not Proxmox VE!"
        if [[ "$bver" != "5" || "$bver" != "6" ]];then
            echo "您的系统版本无法安装!"
            echo "Your Proxmox VE version can not install!"
            sleep 2
            main
        fi
        sleep 2
        main
    fi
    if [[ ! -f "$js" || ! -f "$pm" ]];then
        echo "您的Proxmox VE版本不支持此方式！"
        echo "Your Proxmox VE's version is not supported,Now quit!"
        sleep 2
        main
    fi
    if [[ -f "$js.backup" && -f "$sh" ]];then
        echo "您已经安装过本软件，请不要重复安装！"
        echo "You already installed,Now quit!"
        sleep 3
        chSensors
    fi
    if [ ! -f "/usr/bin/sensors" ];then
        echo "您还没有安装lm-sensors，将会自动进行安装配置："
        echo "you have not installed lm-sensors, auto install now."
        apt -y install lm-sensors
    fi
    sensors-detect --auto > /tmp/sensors
    drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
    if [ `echo $drivers|wc -w` = 0 ];then
        echo -e "\033[31mSensors driver not found.\033[0m"
        echo -e "\033[31m没有找到任何驱动，似乎你的系统不支持。\033[0m"
        sleep 3
        chSensors
    else
        for i in $drivers;do modprobe $i;done
        sensors
        echo -e "\033[31mInstall complete,if everything ok ,it's showed sensors.\033[0m"
        echo -e "\033[31m安装配置成功，如果没有意外，上面已经显示sensors。\033[0m"
    fi
    rm /tmp/sensors
    echo "您的系统是：$pve, 您将安装sensors界面，是否继续？(y/n)"
    echo -n "Your OS：$pve, you will install sensors interface, continue?(y/n)"
    #if [ `/usr/bin/pveversion|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'` != "5" ];then
    #    echo ""
    #    echo -e "\033[31mPve 6.x not support websites display change yet.You can use sensors command.\033[0m"
    #    echo -e "\033[31mPve 6.x暂不支持网页配置显示，请使用sensors命令.\033[0m"
    #    sleep 3
    #    chSensors
    #fi
    if [ $1 ];then
        x=a
    else
        read x
    fi
    case "$x" in
    y | yes | a )
        cp $js $js.backup
        cp $pm $pm.backup
        cat << EOF > /usr/bin/s.sh
r=\`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/,$//g'|sed 's/°C/C/g'\`
r="{"\$r"}"
echo \$r
EOF
        chmod +x /usr/bin/s.sh
        #--create the configs--
        d=`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk -F ":" '{print $1}'`
        if [ -f ./p1 ];then rm ./p1;fi
        cat << EOF >> ./p1
        ,{
            xtype: 'box',
            colspan: 2,
	    title: gettext('Sensors Data:'),
            padding: '0 0 20 0'
        }
        ,{
            itemId: 'Sensors',
            colspan: 2,
            printBar: false,
            title: gettext('Sensors Data:')
        }
EOF
        for i in $d
        do
        cat << EOF >> ./p1
        ,{
            itemId: '$i',
            colspan: 1,
            printBar: false,
            title: gettext('$i'),
            textField: 'tdata',
            renderer:function(value){
            var d = JSON.parse(value);
            var s = "";
            s = d['$i'];
            return s;
            }
        }
EOF
        done
        cat << EOF >> ./p2
\$res->{tdata} = \`/usr/bin/s.sh\`;
EOF
        #--configs end--
        h=`sensors|awk 'END{print NR}'`
        if [ $h = 0 ];then
            h=400
        else
            let h=$h*9+320
        fi
        n=`sed '/widget.pveNodeStatus/,/height/=' $js -n|sed -n '$p'`
       sed -i ''$n'c \ \ \ \ height:\ '$h',' $js 
        n=`sed '/pveversion/,/\}/=' $js -n|sed -n '$p'`
        sed -i ''$n' r ./p1' $js
        n=`sed '/pveversion/,/version_text/=' $pm -n|sed -n '$p'`
        sed -i ''$n' r ./p2' $pm
        if [ -f ./p1 ];then rm ./p1;fi
        if [ -f ./p2 ];then rm ./p2;fi
        systemctl restart pveproxy

        echo "如果没有意外，已经安装完成！浏览器打开界面刷新看一下概要界面！"
        echo "Installation Complete! Go to websites and refresh to enjoy!"
        sleep 5
        main
        ;;
    n | no )
        sleep 2
        main
        ;;
    * )
        echo "Please input y/n to comfirm!"
        sleep 2
        chSensors
    esac
    ;;
    b )
        js='/usr/share/pve-manager/js/pvemanagerlib.js'
        pm='/usr/share/perl5/PVE/API2/Nodes.pm'
        if [[ ! -f $js.backup && ! -f /usr/bin/sensors ]];then
            echo -e "\033[32mNo sensors found.\033[0m"
            echo -e "\033[32m没有检测到安装，不需要卸载。\033[0m"
        else
            mv $js.backup $js
            mv $pm.backup $pm
            apt -y remove lm-sensors
            echo "Uninstall complete."
            echo "卸载成功。"
            sleep 3
            chSensors
        fi
        ;;
    q )
        main
esac
}
#----------------------functions--end------------------#


#--------------------------function-main-------------------------#
main(){
clear

if [ $L = "en" ];then
  echo -e "\033[32mVersion : 1.3\033[0m"
  echo -e "\033[32mPlease input to choose:\033[0m"
  echo -e "\033[32m[a] \033[31mGuide install.\033[0m"
  echo -e "\033[32m[b] \033[31mConfig apt source(change to ustc.edu.cn and so on).\033[0m"
  echo -e "\033[32m[c] \033[31mInstall & config samba.\033[0m"
  echo -e "\033[32m[d] \033[31mInstall mailutils and config root email.\033[0m"
  echo -e "\033[32m[e] \033[31mConfig zfs_arc_max & Install zfs-zed.\033[0m"
  echo -e "\033[32m[f] \033[31mInstall & config VIM.\033[0m"
  echo -e "\033[32m[g] \033[31mInstall cpufrequtils to save power.\033[0m"
  echo -e "\033[32m[h] \033[31mConfig hard disks to spindown.\033[0m"
  echo -e "\033[32m[i] \033[31mConfig PCI hardware pass-thrugh.\033[0m"
  echo -e "\033[32m[j] \033[31mConfig web interface to display sensors data.\033[0m"
  echo -e "\033[32m[k] \033[31mConfig enable Nested virtualization.\033[0m"
  echo -e "\033[32m[l] \033[31mRemove subscribe notice.\033[0m"
  echo -e "\033[32m[u] Upgrade this script to new version.\033[0m"
  echo -e "\033[32m[lang] Change Language.\033[0m"
  echo -e "\033[32m[exit|q] Quit.\033[0m"
  echo -e "\033[32mInput:\033[0m"
else
  echo -e "\033[32mVersion : 1.3\033[0m"
  echo -e "\033[32m请输入序号选择相应的配置：\033[0m"
  echo -e "\033[32m[a] \033[31m无脑引导安装\033[0m"
  echo -e "\033[32m[b] \033[31m配置apt源(更换为ustc.edu.cn,去除企业源等)\033[0m(100%)"
  echo -e "\033[32m[c] \033[31m安装配置samba\033[0m(100%)"
  echo -e "\033[32m[d] \033[31m安装配置root邮件通知\033[0m(100%)"
  echo -e "\033[32m[e] \033[31m安装配置zfs最大内存及zed通知\033[0m(100%)"
  echo -e "\033[32m[f] \033[31m安装配置VIM\033[0m(100%)"
  echo -e "\033[32m[g] \033[31m安装配置CPU省电\033[0m(100%)"
  echo -e "\033[32m[h] \033[31m安装配置硬盘休眠\033[0m(100%)"
  echo -e "\033[32m[i] \033[31m配置PCI硬件直通\033[0m(0%)"
  echo -e "\033[32m[j] \033[31m配置pve的web界面显示传感器温度\033[0m(100%)"
  echo -e "\033[32m[k] \033[31m配置开启嵌套虚拟化\033[0m(100%)"
  echo -e "\033[32m[l] \033[31m去除订阅提示\033[0m(100%)"
  echo -e "\033[32m[u] \033[31m升级该pvetools脚本到最新版本\033[0m"
  echo -e "\033[32m[lang] Change Language\033[0m"
  echo -e "\033[32m[exit|q] 退出\033[0m"
  echo -e "\033[32mInput:\033[0m"
fi
read i
case "$i" in 
a | A )
    echo "Not support!Please choose other options."
    echo "本版本已不支持无脑更新，请选择具体项目进行操作！"
    sleep 3
    main
    chSource wn
    chSamba wn
    chMail wn
#    chZfs wn
    chVim wn
#    chCpu wn
    chSpindown wn
    chNestedV wn
    chSubs wn
    chSensors wn
    echo "Config complete!Back to main menu 5s later."
    echo "已经完成配置！5秒后返回主界面。"
    echo "5"
    sleep 1
    echo "4"
    sleep 1
    echo "3"
    sleep 1
    echo "2"
    sleep 1
    echo "1"
    sleep 1
    main
    ;;
b | B )
    chSource
    main
    ;;
c | C )
    chSamba
    main
    ;;
d | D )
    chMail
    main
    ;;
e | E )
    chZfs
    main
    ;;
f | F )
    chVim
    main
    ;;
g | G )
    chCpu
    main
    ;;
h | H )
    chSpindown
    main
    ;;
i | I )
    echo "not support yet."
    sleep 2
    main
    ;;
j | J )
    chSensors
    sleep 2
    main
    ;;
k | K )
    clear
    chNestedV
    main
    ;;
l | L )
    chSubs
    main
    ;;

u )
    git pull \
    && echo "done!" \
    && sleep 3 \
    && ./pvetools.sh
    ;;
lang )
    if [ $L = "zh" ];then
        L="en"
    else
        L="zh"
    fi
    main
    ;;
exit | quit | q )
    exit
    ;;
* )
    echo "Please comfirm!"
	echo "请重新输入!"
    sleep 2
    main
esac
}
#----------------------functions--end------------------#
if [ `export|grep "zh_CN"|wc -l` = 0 ];then
    L="en"
else
    L="zh"
fi
main
