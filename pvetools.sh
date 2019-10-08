#!/bin/bash
#############--proxmox tools--##########################
#  Author : 龙天ivan                        
#  Mail: ivanhao1984@qq.com
#  Version: V2.0                          
#  Github: https://github.com/ivanhao/pvetools
########################################################

#js whiptail --title "Success" --msgbox "c" 10 60
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
example(){
#msgbox
whiptail --title "Success" --msgbox "
" 10 60
#yesno
if (whiptail --title "Yes/No Box" --yesno "
" 10 60);then
    echo ""
fi
#password
PASSWORD=$(whiptail --title "Password Box" --passwordbox "
Enter your password and choose Ok to continue.
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your password is:" $m
fi
}

smbp(){
m=$(whiptail --title "Password Box" --passwordbox "
Enter samba user 'admin' password: 
请输入samba用户admin的密码：
                " 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    while [ true ]
    do
        if [[ ! `echo $m|grep "^[0-9a-zA-Z.-@]*$"` ]] || [[ $m = '^M' ]];then
            whiptail --title "Success" --msgbox "
Wrong format!!!   input again:
密码格式不对！！！请重新输入：
            " 10 60
            smbp
        else
            break
        fi
    done
fi
}

#修改debian的镜像源地址：
chSource(){
clear
if [ $1 ];then
    #x=a
    whiptail --title "Warnning" --msgbox "Not supported!
    不支持该模式。" 10 60
    chSource
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
    whiptail --title "Warnning" --msgbox "Not supported!
    您的版本不支持！无法继续。" 10 60
    main
fi
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "Config apt source:" 25 55 15 \
    "a" "Automation mode." \
    "b" "Change to ustc.edu.cn." \
    "c" "Disable enterprise." \
    "d" "Undo Change." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "配置apt镜像源:" 25 35 15 \
    "a" "无脑模式" \
    "b" "更换为国内ustc.edu.cn源" \
    "c" "关闭企业更新源" \
    "d" "还原配置" \
    "q" "返回主菜单" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
    if (whiptail --title "Yes/No Box" --yesno "修改为ustc.edu.cn源，禁用企业订阅更新源，添加非订阅更新源(ustc.edu.cn),修改ceph镜像更新源" 10 60) then
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
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
            apt-get update
            apt-get -y install net-tools
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
        else
            whiptail --title "Success" --msgbox " Already changed apt source to ustc.edu.cn!
            已经更换apt源为 ustc.edu.cn" 10 60
        fi
        if [ ! $1 ];then
            chSource
        fi
    fi
    ;;
	b | B  )
        if (whiptail --title "Yes/No Box" --yesno "修改更新源为ustc.edu.cn(包括ceph))?" 10 60) then
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
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
            apt-get update
            apt-get -y install net-tools
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
        else
            whiptail --title "Success" --msgbox " Already changed apt source to ustc.edu.cn!
            已经更换apt源为 ustc.edu.cn" 10 60
        fi
        chSource
    fi
    ;;
c | C  )
    if (whiptail --title "Yes/No Box" --yesno "禁用企业订阅更新源?" 10 60) then
        #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
        if [ -f /etc/apt/sources.list.d/pve-no-sub.list ];then
            #修改pve 5.x更新源地址为非订阅更新源，不使用企业订阅更新源
            echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
        fi
        if [ `grep "^deb" /etc/apt/sources.list.d/pve-enterprise.list|wc -l` != 0 ];then
            #关闭pve 5.x企业订阅更新源
            sed -i 's|deb|#deb|' /etc/apt/sources.list.d/pve-enterprise.list
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
        else
            whiptail --title "Success" --msgbox " apt source has been changed successfully!
            软件源已更换成功！" 10 60
        fi
        chSource
    fi
    ;;
d | D )
    cp /etc/apt/sources.list.bak /etc/apt/sources.list
    cp /etc/apt/sources.list.d/pve-no-sub.list.bak /etc/apt/sources.list.d/pve-no-sub.list
    cp /etc/apt/sources.list.d/pve-enterprise.list.bak /etc/apt/sources.list.d/pve-enterprise.list
    cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
    whiptail --title "Success" --msgbox "apt source has been changed successfully!
    软件源已更换成功！" 10 60
    chSource
    ;;
q )
    echo "q"
    #main
    ;;
esac
fi
}

chMail(){
#set mailutils to send mail
if [ -f /etc/mailname ];then
    echo -e "It seems you have already configed it before."
    echo -e "您好像已经配置过这个了。"
    c="ok"
fi
echo -e "Will you want to config mailutils & postfix to send notification?(Y/N):"
echo -e "是否配置mailutils和postfix来发送邮件通知？(Y/N):"
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
        echo -e "Input email adress:"
        echo -e "输入邮箱地址："
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
        echo -e "Config complete and send test email to you."
        echo -e "已经配置好并发送了测试邮件。"
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
    echo -e "set max zfs ram 4(G) or 8(G) etc, just enter number or n?(number/n) "
    echo -e "设置最大zfs内存（zfs_arc_max),比如4G或8G等, 只需要输入纯数字即可，比如4G输入4?(number/n) "
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
                echo -e "Config complete!you should reboot later."
                echo -e "配置完成，一会儿最好重启一下系统。"
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
    echo -e "Install zfs-zed to get email notification of zfs scrub?(Y/n):"
    echo -e "安装zfs-zed来发送zfs scrub的结果提醒邮件？(Y/n):"
    if [ $1 ];then
        zed=a
    else
        read zed
    fi
    case "$zed" in 
    y | yes | a )
        apt -y install zfs-zed 
        echo -e "Install complete!"
        echo -e "安装zfs-zed成功！"
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
    echo -e "It seems you have already configed it before."
    echo -e "您好像已经配置过这个了。"
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
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "Config samba:" 25 55 15 \
    "a" "Install samba and config user." \
    "b" "Add folder to share." \
    "C" "Delete folder to share." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "配置samba:" 25 55 15 \
    "a" "安装配置samba并配置好samba用户" \
    "b" "添加共享文件夹" \
    "c" "删除共享文件夹" \
    "q" "返回主菜单" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep samba /etc/group|wc -l` = 0 ];then
            if (whiptail --title "Yes/No Box" --yesno "set samba and admin user for samba?
安装samba并配置admin为samba用户？
                " 10 60);then
                apt -y install samba
                groupadd samba
                useradd -g samba -M -s /sbin/nologin admin
                m=$(whiptail --title "Password Box" --passwordbox "
Enter samba user 'admin' password: 
请输入samba用户admin的密码：
                " 10 60 3>&1 1>&2 2>&3)
                exitstatus=$?
                if [ $exitstatus = 0 ]; then
                    while [ true ]
                    do
                        if [[ ! `echo $m|grep "^[0-9a-zA-Z.-@]*$"` ]] || [[ $m = '^M' ]];then
                            echo -e "Wrong format!!!   input again:"
                            echo -e "密码格式不对！！！请重新输入："
                            read m
                        else
                            break
                        fi
                    done
                    echo -e "$m\n$m"|smbpasswd -a admin
                    service smbd restart
                    echo -e "已成功配置好samba，请记好samba用户admin的密码！"
                fi
            fi
        else
            whiptail --title "Success" --msgbox "Already configed samba.
已配置过samba，没什么可做的!
" 10 60
                    fi
        if [ ! $1 ];then
            chSamba
        fi
        ;;
    b | B )
        echo -e "Exist share folders:"
        echo -e "已有的共享目录："
        echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
        echo -e "Input share folder path:"
        echo -e "输入共享文件夹的路径:"
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
            echo -e "Input share name:"
            echo -e "输入共享名称："
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
        echo -e "Exist share folders:"
        echo -e "已有的共享目录："
        echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
        echo -e "Input share name:"
        echo -e "输入共享名称："
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
    esac
fi
}

chVim(){
#config vim
if [ $L = "en" ];then
    echo -e "Install vim and config:"
    echo -e "[a] Install vim & simply config display."
    echo -e "[b] Install vim & config 'vim-for-server'(https://github.com/wklken/vim-for-server)."
else
    echo -e "安装配置VIM！"
    echo -e "[a] 安装VIM并简单配置，如配色行号等，基本是vim原味儿。"
    echo -e "[b] 安装VIM并配置'vim-for-server'(https://github.com/wklken/vim-for-server)."
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
    echo -e "Config hard drives to auto pindown?(Y/n):"
    echo -e "配置硬盘自动休眠？(Y/n):"
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
            echo -e "Input number of .bake to auto spindown:"
            echo -e "输入硬盘自动休眠的检测时间，周期为分钟，输入5为5分钟:"
            read x
            while [ true ]
            do
                if [[ `echo "$x"|grep "[0-9]*"|wc -l` = 0 ]] || [[ $x = "" ]];then
                    echo -e "输入格式错误，请重新输入："
                    read x
                else
                    break
                fi
            done
            cat << EOF >> /etc/crontab
*/$x * * * * root /root/hdspindown/spindownall
EOF
            service cron reload
            echo -e "Config every $x .bake to check disks and auto spindown:"
            echo -e "已为您配置好硬盘每$x分钟自动检测硬盘和休眠。"
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
    echo -e "It seems you have already configed it before."
    echo -e "您好像已经配置过这个了。"
    sleep 2
    main
fi
}

chCpu(){
#setup for cpufreq
if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
    echo -e "Install cpufrequtils to save power?(Y/n):"
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
                    echo -e "输入格式错误,请重新输入："
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
                    echo -e "输入格式错误，请重新输入："
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
            echo -e "  cpufrequtils need to reboot to apply! Please reboot.  "
            echo -e "  cpufrequtils 安装好后需要重启系统，请稍后重启。"
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
    echo -e "It seems you have already configed it before."
    echo -e "您好像已经配置过这个了。"
    sleep 2
fi
}

chSubs(){
    clear
    case $L in
        en )
            echo -e "Remove subscribe notice."
            ;;
        zh )
            echo -e "去除订阅提示"
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
            echo -e "[a] Enable nested"
            echo -e "[b] Set vm to nested."
            echo -e "[q] back to main menu."
            ;;
        zh )
            echo -e "[a] 开启嵌套虚拟化"
            echo -e "[b] 开启某个虚拟机的嵌套虚拟化"
            echo -e "[q] 返回主菜单"
            ;;
    esac
    if [ $1 ];then
        x=a
    else
        read x
    fi
    case "$x" in
        a )
            echo -e "Are you sure to enable Nested? (Y/n):"
            echo -e "确定要开启嵌套虚拟化吗？(Y/n):"
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
                    echo -e "Please input your vmid:"
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
echo -e "安装配置lm-sensors并配置web界面显示温度。"
echo -e "Install lm-sensors and config web interface to display sensors data."
case $L in
    en )
        echo -e "[a] Install"
        echo -e "[b] Uninstall"
        echo -e "[q] back to main menu."
        ;;
    zh )
        echo -e "[a] 安装"
        echo -e "[b] 卸载"
        echo -e "[q] 返回主菜单"
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
        echo -e "Sensors driver not found."
        echo -e "没有找到任何驱动，似乎你的系统不支持。"
        sleep 3
        chSensors
    else
        for i in $drivers;do modprobe $i;done
        sensors
        echo -e "Install complete,if everything ok ,it's showed sensors."
        echo -e "安装配置成功，如果没有意外，上面已经显示sensors。"
    fi
    rm /tmp/sensors
    echo "您的系统是：$pve, 您将安装sensors界面，是否继续？(y/n)"
    echo -n "Your OS：$pve, you will install sensors interface, continue?(y/n)"
    #if [ `/usr/bin/pveversion|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'` != "5" ];then
    #    echo ""
    #    echo -e "Pve 6.x not support websites display change yet.You can use sensors command."
    #    echo -e "Pve 6.x暂不支持网页配置显示，请使用sensors命令."
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
            echo -e "No sensors found."
            echo -e "没有检测到安装，不需要卸载。"
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
#    "a" "无脑模式" \
          #  a )
          #      if (whiptail --title "Test Yes/No Box" --yesno "Choose between Yes and No." 10 60) then
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      else
          #          whiptail --title "OK" --msgbox "OK" 10 60
          #      fi
          #      sleep 3
          #      main
          #      ;;
          #  b )
          #      echo "b"
          #      ;;
          #  c )
          #      echo "c"
          #      ;;

main(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "Please choose:" 25 75 15 \
    "a" "Guide install." \
    "b" "Config apt source(change to ustc.edu.cn and so on)." \
    "c" "Install & config samba." \
    "d" "Install mailutils and config root email." \
    "e" "Config zfs_arc_max & Install zfs-zed." \
    "f" "Install & config VIM." \
    "g" "Install cpufrequtils to save power." \
    "h" "Config hard disks to spindown." \
    "i" "Config PCI hardware pass-thrugh." \
    "j" "Config web interface to display sensors data." \
    "k" "Config enable Nested virtualization." \
    "l" "Remove subscribe notice." \
    "u" "Upgrade this script to new version." \
    "lang" "Change Language." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0 " --menu "请选择相应的配置：" 25 55 15 \
    "b" "配置apt源(更换为ustc.edu.cn,去除企业源等)" \
    "c" "安装配置samba" \
    "d" "安装配置root邮件通知" \
    "e" "安装配置zfs最大内存及zed通知" \
    "f" "安装配置VIM" \
    "g" "安装配置CPU省电" \
    "h" "安装配置硬盘休眠" \
    "i" "配置PCI硬件直通" \
    "j" "配置pve的web界面显示传感器温度" \
    "k" "配置开启嵌套虚拟化" \
    "l" "去除订阅提示" \
    "u" "升级该pvetools脚本到最新版本" \
    "lang" "Change Language" \
    3>&1 1>&2 2>&3)
fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$OPTION" in
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
            if (whiptail --title "Yes/No Box" --yesno "Change Language?
修改语言？" 10 60);then
                if [ $L = "zh" ];then
                    L="en"
                else
                    L="zh"
                fi
                main
                #main $L
            fi
            ;;
        exit | quit | q )
            exit
            ;;
        esac
    else
        exit
    fi
}
main1(){
clear
if [[ $1 = "en" || $1 = "zh" ]];then
    L=$1
fi
if [ $L = "en" ];then
  echo -e "Version : 1.3"
  echo -e "Please input to choose:"
  echo -e "[a] Guide install."
  echo -e "[b] Config apt source(change to ustc.edu.cn and so on)."
  echo -e "[c] Install & config samba."
  echo -e "[d] Install mailutils and config root email."
  echo -e "[e] Config zfs_arc_max & Install zfs-zed."
  echo -e "[f] Install & config VIM."
  echo -e "[g] Install cpufrequtils to save power."
  echo -e "[h] Config hard disks to spindown."
  echo -e "[i] Config PCI hardware pass-thrugh."
  echo -e "[j] Config web interface to display sensors data."
  echo -e "[k] Config enable Nested virtualization."
  echo -e "[l] Remove subscribe notice."
  echo -e "[u] Upgrade this script to new version."
  echo -e "[lang] Change Language."
  echo -e "[exit|q] Quit."
  echo -e "Input:"
else
  echo -e "Version : 1.3"
  echo -e "请输入序号选择相应的配置："
  echo -e "[a] 无脑引导安装"
  echo -e "[b] 配置apt源(更换为ustc.edu.cn,去除企业源等)(100%)"
  echo -e "[c] 安装配置samba(100%)"
  echo -e "[d] 安装配置root邮件通知(100%)"
  echo -e "[e] 安装配置zfs最大内存及zed通知(100%)"
  echo -e "[f] 安装配置VIM(100%)"
  echo -e "[g] 安装配置CPU省电(100%)"
  echo -e "[h] 安装配置硬盘休眠(100%)"
  echo -e "[i] 配置PCI硬件直通(0%)"
  echo -e "[j] 配置pve的web界面显示传感器温度(100%)"
  echo -e "[k] 配置开启嵌套虚拟化(100%)"
  echo -e "[l] 去除订阅提示(100%)"
  echo -e "[u] 升级该pvetools脚本到最新版本"
  echo -e "[lang] Change Language"
  echo -e "[exit|q] 退出"
  echo -e "Input:"
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
#if [ `export|grep "zh_CN"|wc -l` = 0 ];then
#    L="en"
#else
#    L="zh"
#fi
if (whiptail --title "Language" --yes-button "中文" --no-button "English"  --yesno "Choose Language:
选择语言：" 10 60) then
    L="zh"
else
    L="en"
fi
main
