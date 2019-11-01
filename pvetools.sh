#!/bin/bash
#############--proxmox tools--##########################
#  Author : 龙天ivan
#  Mail: ivanhao1984@qq.com
#  Version: V2.0.1
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


#input form
NAME=$(whiptail --title "
Free-form Input Box
" --inputbox "
What is your pet's name?
" 10 60 
Peter
3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "" 
else
    echo "" 
fi

#processing
{
    echo 50
    sleep 1
    $(apt -y install mailutils)
    echo 100
    sleep 1
} | whiptail --gauge "Please wait while installing" 6 60 0
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
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config apt source:" 25 60 15 \
    "a" "Automation mode." \
    "b" "Change to ustc.edu.cn." \
    "c" "Disable enterprise." \
    "d" "Undo Change." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置apt镜像源:" 25 60 15 \
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
addMail(){
if (whiptail --title "Yes/No Box" --yesno "
Will you want to config mailutils & postfix to send notification?(Y/N):
是否配置mailutils和postfix来发送邮件通知？
" 10 60);then
    qqmail=$(whiptail --title "Config mail" --inputbox "
Input email adress:
输入邮箱地址：
    " 10 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo $qqmail|grep '^[a-zA-Z0-9\_\-\.]*\@[A-Za-z\_\-\.]*\.[a-zA-Z\_\-\.]*$'` ];then
                    break
            else
                whiptail --title "Warnning" --msgbox "
Wrong email format!!!   input xxxx@qq.com for example.retry:
错误的邮箱格式！！！请输入类似xxxx@qq.com并重试：
                " 10 60
                addMail
            fi
        done
        if [[ ! -f /etc/mailname || `dpkg -l|grep mailutils|wc -l` = 0 ]];then
            {
                echo 50
                sleep 1
                $(apt -y install mailutils)
                echo 100
                sleep 1
            } | whiptail --gauge "Please wait while installing" 10 60 0
        fi
        {
            echo 10
            sleep 1
            $(echo "pve.local" > /etc/mailname)
            echo 40
            sleep 1
            $(sed -i -e "/root:/d" /etc/aliases)
            echo 70
            sleep 1
            $(echo "root: $qqmail">>/etc/aliases)
            echo 100
            sleep 1
        } | whiptail --gauge "Please wait while installing" 10 60 0
        sleep 1
        dpkg-reconfigure postfix
        service postfix reload
        echo "This is a mail test." |mail -s "mail test" root
        whiptail --title "Success" --msgbox "
Config complete and send test email to you.
已经配置好并发送了测试邮件。
        " 10 60
        main
    else
        main
    fi
else
    main
fi
}
if [ -f /etc/mailname ];then
    if (whiptail --title "Yes/No Box" --yesno "
It seems you have already configed it before.Reconfig?
您好像已经配置过这个了。重新配置？
    " --defaultno 10 60);then
        addMail
    else
        main
    fi
fi
addMail
}

chZfs(){
#set max zfs ram
setMen(){
    x=$(whiptail --title "Config mail" --inputbox "
set max zfs ram 4(G) or 8(G) etc, just enter number or n?
设置最大zfs内存（zfs_arc_max),比如4G或8G等, 只需要输入纯数字即可，比如4G输入4?
    " 10 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ "$x" =~ ^[1-9]+$ ]]; then
                {
                    $(echo "options zfs zfs_arc_max=$[$x*1024*1024*1024]">/etc/modprobe.d/zfs.conf)
                    echo 10
                    $(update-initramfs -u)
                    echo 70
                    sleep 1
                    #set rpool to list snapshots
                    $(if [ `zpool get listsnapshots|grep rpool|awk '{print $3}'` = "off" ];then
                        zpool set listsnapshots=on rpool
                    fi)
                    echo 100
                }|whiptail --gauge "installing" 10 60 0
                whiptail --title "Success" --msgbox "
Config complete!you should reboot later.
配置完成，一会儿最好重启一下系统。
                " 10 60
                break
            else
                whiptail --title "Warnning" --msgbox "
Invalidate value.Please comfirm!
输入的值无效，请重新输入!
                " 10 60
                setMen
            fi
        done
        #zfs-zed
        if (whiptail --title "Yes/No Box" --yesno "
    Install zfs-zed to get email notification of zfs scrub?(Y/n):
    安装zfs-zed来发送zfs scrub的结果提醒邮件？(Y/n):
        " 10 60);then
            {
                echo 10
                $(
                    if [ `dpkg -l|grep zfs-zed|wc -l` = 0 ];then
                        apt -y install zfs-zed
                    fi
                )
                echo 100
                sleep 1
            }|whiptail --gauge "installing" 10 60 0
            whiptail --title "Success" --msgbox "
    Install complete!
    安装zfs-zed成功！
            " 10 60
        fi
    else
        main
    fi
}
if [ ! -f /etc/modprobe.d/zfs.conf ] || [ `grep "zfs_arc_max" /etc/modprobe.d/zfs.conf|wc -l` = 0 ];then
    setMen
else
    if(whiptail --title "Yes/No box" --yesno "
It seems you have already configed it before.Reconfig?
您好像已经配置过这个了。是否重新配置？
    " --defaultno 10 60 );then
        setMen
    else
        main
    fi
fi
}

chSamba(){
#config samba
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config samba:" 25 60 15 \
    "a" "Install samba and config user." \
    "b" "Add folder to share." \
    "c" "Delete folder to share." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置samba:" 25 60 15 \
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
                smbp
                echo -e "$m\n$m"|smbpasswd -a admin
                service smbd restart
                echo -e "已成功配置好samba，请记好samba用户admin的密码！"
                whiptail --title "Success" --msgbox "
已成功配置好samba，请记好samba用户admin的密码！
                " 10 60
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
       # echo -e "Exist share folders:"
       # echo -e "已有的共享目录："
       # echo "`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'`"
       # echo -e "Input share folder path:"
       # echo -e "输入共享文件夹的路径:"
       addFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        x=$(whiptail --title "Add Samba Share folder" --inputbox "
Exist share folders:
已有的共享目录：
----------------------------------------
$(grep -E "^\[[0-9a-zA-Z.-]*\]$|^path" /etc/samba/smb.conf|awk 'NR>3{print $0}'|sed 's/path/        path/')
----------------------------------------
Input share folder path(like /root):
输入共享文件夹的路径(只需要输入/root类似的路径):
" $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ ! -d $x ]
            do
                whiptail --title "Success" --msgbox "Path not exist!
路径不存在！
                " 10 60
                addFolder
            done
            while [ `grep "path \= ${x}$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                whiptail --title "Success" --msgbox "Path exist!
路径已存在！
                " 10 60
                addFolder
            done
            n=`echo $x|grep -o "[a-zA-Z0-9.-]*$"`
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
            do
                n=$(whiptail --title "Samba Share folder" --inputbox "
Input share name:
输入共享名称：
    " 10 60 "" 3>&1 1>&2 2>&3)
                exitstatus=$?
                if [ $exitstatus = 0 ]; then       
                    while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ]
                    do
                        whiptail --title "Success" --msgbox "Name exist!
名称已存在！
                        " 10 60
                        addFolder
                    done
                fi
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
                whiptail --title "Success" --msgbox "
Configed!
配置成功！
                " 10 60
                service smbd restart
            else
                whiptail --title "Success" --msgbox "Already configed！
已经配置过了！
                " 10 60
            fi
            addFolder
        else
            chSamba
        fi
}
        addFolder
        ;;
    c )
        delFolder(){
        h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
        if [ $h -lt 3 ];then
            let h=$h*15
        else
            let h=$h*5
        fi
        n=$(whiptail --title "Remove Samba Share folder" --inputbox "
Exist share folders:
已有的共享目录：
----------------------------------------
$(grep -E "^\[[0-9a-zA-Z.-]*\]$|^path" /etc/samba/smb.conf|awk 'NR>3{print $0}'|sed 's/path/        path/')
----------------------------------------
Input share folder name(type words in []):
输入共享文件夹的名称(只需要输入[]中的名字):
        " $h 60 "" 3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` = 0 ]
            do
                whiptail --title "Success" --msgbox "
Name not exist!:
名称不存在！:
                " 10 60
                delFolder
            done
            if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                sed "/\[${n}\]/,/${n} end/d" /etc/samba/smb.conf -i 
                whiptail --title "Success" --msgbox "
Configed!
删除成功！
                " 10 60
                service smbd restart
            fi
            delFolder
        else
            chSamba
        fi
    }
        delFolder
        ;;

    q )
        main
        ;;
    esac
else
    chSamba
fi
}

chVim(){
#config vim
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config VIM:" 12 60 4 \
    "a" "Install vim & simply config display." \
    "b" "Install vim & config 'vim-for-server'." \
    "c" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "安装配置VIM！" 12 60 4 \
    "a" "安装VIM并简单配置，如配色行号等。" \
    "b" "安装VIM并配置'vim-for-server'。" \
    "c" "还原配置。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in 
        a )
        if(whiptail --title "Yes/No Box" --yesno "
Install vim & simply config display.Continue?
安装VIM并简单配置，如配色行号等，基本是vim原味儿。是否继续？
            " 10 60) then
            {
            echo 10
            $(
            if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ] || [ `dpkg -l |grep vim|wc -l` = 0 ];then
                apt -y install vim
            else
                cp ~/.vimrc ~/.vimrc.bak
            fi
            )
            echo 50
            $(
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
            )
            echo 100
            }|whiptail --gauge "installing" 10 60
            whiptail --title "Success" --msgbox "
    Install & config complete!
    安装配置完成!
            " 10 60
        else
            chVim
        fi
            ;;
        b | B )
        if(whiptail --title "Yes/No Box" --yesno "
安装VIM并配置 \'vim-for-server\'(https://github.com/wklken/vim-for-server).
yes or no?
            " 12 60) then
            {
            echo 10
            $(
            apt -y install curl vim
            )
            echo 80
            $(
            cp ~/.vimrc ~/.vimrc_bak
            curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc
            )
            echo 100
        }|whiptail --gauge "installing" 10 60
            whiptail --title "Success" --msgbox "
    Install & config complete!
    安装配置完成！
            " 10 60
        else
            chVim
        fi
            ;;
        c )
            if(whiptail --title "Yes/No Box" --yesno "
Remove Config?
确认要还原配置？
                " --defaultno 10 60) then
                cp ~/.vimrc.bak ~/.vimrc
                whiptail --title "Success" --msgbox "
Done
已经完成配置
                " 10 60
            else
                chVim
            fi
    esac
else
    main
fi
}

chSpindown(){
#set hard drivers to spindown
spinTime(){
    x=$(whiptail --title "config" --inputbox "
input number of minite to auto spindown:
输入硬盘自动休眠的检测时间，周期为分钟，输入5为5分钟:
    " 10 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ];then
                whiptail --title "Warnning" --msgbox "
输入格式错误，请重新输入：
                " 10 60
                spinTime
            else
                break
            fi
        done
        cat << eof >> /etc/crontab
*/$x * * * * root /root/hdspindown/spindownall
eof
        service cron reload
        whiptail --title "Success" --msgbox "
config every $x minite to check disks and auto spindown:
已为您配置好硬盘每$x分钟自动检测硬盘和休眠。
        " 10 60
    fi
}
doSpindown(){
    if(whiptail --title "Yes/No Box" --yesno "
    Config hard drives to auto spindown?(Y/n):
    配置硬盘自动休眠？(Y/n):
    " 10 60) then
    {
        echo 10
        if [ `dpkg -l|grep git|wc -l` = 0 ];then
            apt -y install git
        fi
        echo 50
        cd /root
        $(
            git clone https://github.com/ivanhao/hdspindown.git 2>&1 &
        )
        echo 90
        cd hdspindown
        chmod +x *.sh
        ./spindownall
        echo 100
    }   | whiptail --gauge "installing" 10 60 0
        if [ `grep "spindownall" /etc/crontab|wc -l` = 0 ];then
            spinTime
        fi
    else
        chSpindown
    fi
}

if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config hard disks spindown:" 25 60 15 \
    "a" "Config hard drives to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置硬盘自动休眠" 25 60 15 \
    "a" "配置硬盘自动休眠" \
    "b" "还原硬盘自动休眠配置" \
    "c" "配置pvestatd服务（防止休眠后马上被唤醒）。" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ ! -f /root/hdspindown/spindownall ];then
            doSpindown
        else
            whiptail --title "Yes/No Box" --msgbox "
It seems you have already configed it before.
您好像已经配置过这个了。
                " 10 60
            chSpindown
        fi
        ;;
    b )
        if(whiptail --title "Yes/No Box" --yesno "
Remove config spindown?
确认要还原配置？
        " 10 60) then
            sed -i '/spindownall/d' /etc/crontab
            rm /usr/bin/hdspindown
            if(whiptail --title "Yes/No Box" --yesno "
Remove source code?
是否要删除休眠程序代码？
            " 10 60) then
                rm -rf /root/hdspindown
            fi
            whiptail --title "Success" --msgbox "
OK
已经完成配置
            " 10 60
        else
            chSpindown
        fi
        ;;
    c )
        if (whiptail --title "Enable/Disable pvestatd" --yes-button "停止(Disable)" --no-button "启动(Enable)"  --yesno "
pvestatd may spinup the drivers,if hdspindown can not effective, you can disable it to make drives to spindown.
使用lvm的时候pvestatd 可能会造成硬盘频繁唤醒从而导致hdspindown无法让你的硬盘休眠，如果需要，你可以在这里停止这个服务。
停止这个服务，在web界面将会显示一些异常，如果需要在web界面进行操作，可以再启动这个服务。这个操作不是必须的，要自己灵活应用。
        " 20 60) then
        {
            pvestatd stop
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        else
        {
            pvestatd start
            echo 100
            sleep 1
        }|whiptail --gauge "configing..." 10 60 50
        fi
        ;;
    esac
fi
}

chCpu(){
maxCpu(){
    info=`cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'`
    x=$(whiptail --title "cpufrequtils" --inputbox "
$info
--------------------------------------------
Input MAX_SPEED(example: 1.6GHz type 1600000):
输入最大频率（示例：1.6GHz 输入1600000）：
    " 20 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "[0-9][0-9][0-9][0-9][0-9][0-9][0-9]"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
示例：1.6GHz 输入1600000
输入格式错误,请重新输入：
                " 15 60
                maxCpu
            else
                break
            fi
        done
        mx=$x
    else
        chCpu
    fi
}
minCpu(){
    x=$(whiptail --title "cpufrequtils" --inputbox "
$info
--------------------------------------------
Input MIN_SPEED(example: 1.6GHz type 1600000):
输入最小频率（示例：1.6GHz 输入1600000）：
    " 20 60   3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "[0-9][0-9][0-9][0-9][0-9][0-9][0-9]"|wc -l` = 0 ]] || [[ $x = "" ]];then
                whiptail --title "Warnning" --msgbox "
example: 1.6GHz type 1600000
retry
示例：1.6GHz 输入1600000
输入格式错误,请重新输入：
                " 15 60
                minCpu
            else
                break
            fi
        done
        mi=$x
    else
        chCpu
    fi
}

#setup for cpufreq
doChCpu(){
if(whiptail --title "Yes/No Box" --yesno "
Install cpufrequtils to save power?
安装配置CPU省电?
" --defaultno 10 60) then
{
    echo 10
    if [ `dpkg -l|grep cpufrequtils|wc -l` = 0 ];then
        apt -y install cpufrequtils
    fi
    echo 50
    if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub 
        update-grub
    fi
    if [ ! -f /etc/default/cpufrequtils ];then
        cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    fi
    echo 100
    sleep 1
}|whiptail --gauge "installing..." 10 60 0
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="powersave"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
    whiptail --title "Success" --msgbox "
cpufrequtils need to reboot to apply! Please reboot.  
cpufrequtils 安装好后需要重启系统，请稍后重启。
    " 10 60
else
    main
fi
}
#-------------chCpu--main---------------
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Config cpufrequtils to save power." \
    "b" "Remove config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "安装配置CPU省电" 25 60 15 \
    "a" "安装配置CPU省电" \
    "b" "还原配置" \
    3>&1 1>&2 2>&3)
fi
if [ $1 ];then
    OPTION=a
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a | A )
        if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
            doChCpu
        else
            if(whiptail --title "Yes/No Box" --yesno "
        It seems you have already configed it before.
        您好像已经配置过这个了。
            " --defaultno 10 60) then
                doChCpu
            else
                main
            fi
        fi
        ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
continue?
还原配置？
        " --defaultno 10 60 ) then
            sed -i 's/ intel_pstate=disable//g' /etc/default/grub
            rm -rf /etc/default/cpufrequtils
            if (whiptail --title "Yes/No" --yesno "
Uninstall cpufrequtils?
卸载cpufrequtils?
                " 10 60 ) then
            {
                echo 20
                apt -y remove cpufrequtils 2>&1 &
                echo 10
            }  |  whiptail --gauge "Uninstalling..." 10 60 0
            fi
            whiptail --title "Success" --msgbox "
Done
配置完成
            " 10 60
        fi
        chCpu
    esac
fi
#-------------chCpu--main--end------------

}

chSubs(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Remove subscribe notice." \
    "b" "Unset config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "安装配置CPU省电" 25 60 15 \
    "a" "去除订阅提示" \
    "b" "还原配置" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
    a )
        if(whiptail --title "Yes/No" --yesno "
continue?
是否去除订阅提示?
            " 10 60 )then
            if [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 1 ];then
                sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                whiptail --title "Success" --msgbox "
Done!!
去除成功！
                " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
已经去除过了，不需要再次去除。
                " 10 60
            fi
        fi
        ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
continue?
是否还原订阅提示?
            " 10 60) then
            if [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 0 ];then
                mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                whiptail --title "Success" --msgbox "
Done!!
还原成功！
                " 10 60
            else
                whiptail --title "Success" --msgbox "
You already removed.
已经还原过了，不需要再次还原。
                " 10 60
            fi
        fi
        ;;
    esac
fi
}
chSmartd(){
  hds=`lsblk|grep "^[s,h]d[a-z]"|awk '{print $1}'`
}

chNestedV(){
clear
unsetVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.0.2 " --menu "
Choose vmid to unset nested:
选择需要关闭嵌套虚拟化的vm：" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
你选的是：$vmid ，是否继续?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
    输入格式错误，请重新输入：
                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                whiptail --title "Success" --msgbox "
    You already unseted.Nothing to do.
    您的虚拟机未开启过嵌套虚拟化支持。
                " 10 60
            else
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                sed -i '/,+vmx/d' /etc/pve/qemu-server/$vmid.conf
                echo  "args: "$args >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Unset OK.Please reboot your vm.
    您的虚拟机已经关闭嵌套虚拟化支持。重启虚拟机后生效。
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
setVmN(){
    list=`qm list|awk 'NR>1{print $1":"$2"......."$3" "}'`
    ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}';done`
    h=`echo $ls|wc -l`
    let h=$h*1
    if [ $h -lt 30 ];then
        h=30
    fi
    list1=`echo $list|awk 'NR>1{print $1}'`
    vmid=$(whiptail  --title " PveTools   Version : 2.0.2 " --menu "
Choose vmid to set nested:
选择需要配置嵌套虚拟化的vm：" 25 60 15 \
    $(echo $ls) \
     3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        if(whiptail --title "Yes/No" --yesno "
you choose: $vmid ,continue?
你选的是：$vmid ，是否继续?
            " 10 60)then
            while [ true ]
            do
                if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
    输入格式错误，请重新输入：
                    " 10 60
                    setVmN
                else
                    break
                fi
            done
            if [ `qm showcmd $vmid|grep "+vmx"|wc -l` = 0 ];then
                args=`qm showcmd $vmid|grep "\-cpu [0-9a-zA-Z,+_]*" -o`
                for i in 'boot:' 'memory:' 'core:';do
                    if [ `grep '^'$i /etc/pve/qemu-server/$vmid.conf|wc -l` -gt 0 ];then
                        con=$i
                        break
                    fi
                done
                sed "/"$con"/a\args: $args,+vmx" -i /etc/pve/qemu-server/$vmid.conf
                #echo "args: "$args",+vmx" >> /etc/pve/qemu-server/$vmid.conf
                whiptail --title "Success" --msgbox "
    Nested OK.Please reboot your vm.
    您的虚拟机已经开启嵌套虚拟化支持。重启虚拟机后生效。
                " 10 60
            else
                whiptail --title "Success" --msgbox "
    You already seted.Nothing to do.
    您的虚拟机已经开启过嵌套虚拟化支持。
                " 10 60
            fi
        else
            chNestedV
        fi
    else
        chNestedV
    fi
}
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config Nested:" 25 60 15 \
    "a" "Enable nested" \
    "b" "Set vm to nested" \
    "c" "Unset vm nested" \
    "d" "Disable nested" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置嵌套虚拟化:" 25 60 15 \
    "a" "开启嵌套虚拟化" \
    "b" "开启某个虚拟机的嵌套虚拟化" \
    "c" "关闭某个虚拟机的嵌套虚拟化" \
    "d" "关闭嵌套虚拟化" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "
Are you sure to enable Nested?
It will stop all your runnging vms (Y/n):
确定要开启嵌套虚拟化吗？
这个操作会停止你现在所有运行中的虚拟机!(Y/n):
            " 10 60) then
                if [ `cat /sys/module/kvm_intel/parameters/nested` = 'N' ];then
                    for i in `qm list|awk 'NR>1{print $1}'`;do
                        qm stop $i
                    done
                    modprobe -r kvm_intel  
                    modprobe kvm_intel nested=1
                    if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                        echo "options kvm_intel nested=1" >> /etc/modprobe.d/modprobe.conf
                        whiptail --title "Success" --msgbox "
Nested ok.
您已经开启嵌套虚拟化。
                        " 10 60
                    else
                        whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系统不支持嵌套虚拟化。
                        " 10 60
                    fi
                else
                    whiptail --title "Warnning" --msgbox "
You already enabled nested virtualization.
您已经开启过嵌套虚拟化。
                    " 10 60
                fi
            fi
            chNestedV
            ;;
        b )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
您还没有虚拟机。
                    " 10 60
                else
                    setVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系统不支持嵌套虚拟化。
                " 10 60
                chNestedV
            fi
            ;;
        c )
            if [ `cat /sys/module/kvm_intel/parameters/nested` = 'Y' ];then
                if [ `qm list|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "
You have no vm.
您还没有虚拟机。
                    " 10 60
                else
                    unsetVmN
                fi
                chNestedV
            else
                whiptail --title "Warnning" --msgbox "
Your system can not open nested.
您的系统不支持嵌套虚拟化。
                " 10 60
                chNestedV
            fi
            ;;
        q )
            main
            ;;
    esac
else
    main
fi
}
chSensors(){
#安装lm-sensors并配置在界面上显示
#for i in `sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`;do modprobe $i;done
clear
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config lm-sensors & proxmox ve display:" 25 60 15 \
    "a" "Install." \
    "b" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置samba:" 25 60 15 \
    "a" "安装配置温度显示" \
    "b" "删除配置" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        if(whiptail --title "Yes/No" --yesno "
Your OS：$pve, you will install sensors interface, continue?(y/n)
您的系统是：$pve, 您将安装sensors界面，是否继续？(y/n)
            " 10 60) then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'
            sh='/usr/bin/s.sh'
            ppv=`/usr/bin/pveversion`
            OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
            ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
            bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
            pve=$OS$ver
            if [[ "$OS" != "pve" ]];then
                whiptail --title "Warnning" --msgbox "
您的系统不是Proxmox VE, 无法安装!
Your OS is not Proxmox VE!
                " 10 60
                if [[ "$bver" != "5" || "$bver" != "6" ]];then
                    whiptail --title "Warnning" --msgbox "
您的系统版本无法安装!
Your Proxmox VE version can not install!
                    " 10 60
                    main
                fi
                main
            fi
            if [[ ! -f "$js" || ! -f "$pm" ]];then
                whiptail --title "Warnning" --msgbox "
您的Proxmox VE版本不支持此方式！
Your Proxmox VE\'s version is not supported,Now quit!
                " 10 60
                main
            fi
            if [[ -f "$js.backup" && -f "$sh" ]];then
                whiptail --title "Warnning" --msgbox "
您已经安装过本软件，请不要重复安装！
You already installed,Now quit!
                " 10 60
                chSensors
            fi
            if [ ! -f "/usr/bin/sensors" ];then
                {
                    echo 50
                apt-get -y install lm-sensors
                    echo 100
                    sleep 1
                } | whiptail --gauge "installing lm-sensors" 10 60 0
            fi
            sensors-detect --auto > /tmp/sensors
            drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
            if [ `echo $drivers|wc -w` = 0 ];then
                whiptail --title "Warnning" --msgbox "
Sensors driver not found.
没有找到任何驱动，似乎你的系统不支持。
                " 10 60
                chSensors
            else
                for i in $drivers;do modprobe $i;done
                sensors
                sleep 3
                whiptail --title "Success" --msgbox "
Install complete,if everything ok ,it\'s showed sensors.Next, restart you web.
安装配置成功，如果没有意外，上面已经显示sensors。下一步会重启web界面，请不要惊慌。
                " 20 60
            fi
            rm /tmp/sensors
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
            whiptail --title "Success" --msgbox "
如果没有意外，已经安装完成！浏览器打开界面刷新看一下概要界面！
Installation Complete! Go to websites and refresh to enjoy!
            " 10 60
        else
            chSensors
        fi
    ;;
    b )
        if(whiptail --title "Yes/No" --yesno "
Uninstall?
确认要还原配置？
        " 10 60)then
            js='/usr/share/pve-manager/js/pvemanagerlib.js'
            pm='/usr/share/perl5/PVE/API2/Nodes.pm'
            if [[ ! -f $js.backup && ! -f /usr/bin/sensors ]];then
                whiptail --title "Warnning" --msgbox "
    No sensors found.
    没有检测到安装，不需要卸载。
                " 10 60
            else
            {
                mv $js.backup $js
                mv $pm.backup $pm
                echo 50
                apt-get -y remove lm-sensors
                echo 100
                sleep 1
            }|whiptail --gauge "Uninstalling" 10 60 0
            whiptail --title "Success" --msgbox "
Uninstall complete.
卸载成功。
            " 10 60
            fi
        fi
        chSensors
        ;;
    esac
fi
}

chPassth(){

#--------------funcs-start----------------
enablePass(){
if(whiptail --title "Yes/No Box" --yesno "
Enable PCI Passthrough(need reboot host)?
是否开启硬件直通支持（需要重启物理机）?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
Your hardware do not support PCI Passthrough(No IOMMU)
您的硬件不支持直通！
" 10 60
        chPassth
    fi
    if [ `cat /proc/cpuinfo|wc -l` = 0 ];then
        iommu="amd_iommu=on"
    else
        iommu="intel_iommu=on"
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet '$iommu'|' /etc/default/grub 
    {
        echo 50
        update-grub 2>&1 &
        echo 100
        sleep 1
        }|whiptail --gauge "installing..." 10 60 10
        if [ `grep "vfio" /etc/modules|wc -l` = 0 ];then
            cat <<EOF >> /etc/modules
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
EOF
        fi
        whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.  
    安装好后需要重启系统，请稍后重启。
        " 10 60
    else
        whiptail --title "Warnning" --msgbox "
You already configed!
您已经配置过这个了!
" 10 60
        chPassth
    fi
else
    main
fi
}

disablePass(){
if(whiptail --title "Yes/No Box" --yesno "
disable PCI Passthrough(need reboot host)?
是否关闭硬件直通支持（需要重启物理机）?
" --defaultno 10 60) then
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --yesno "
Your hardware do not support PCI Passthrough(No IOMMU)
您的硬件不支持直通！
" 10 60
        chPassth
    fi
    if [ `cat /proc/cpuinfo|wc -l` = 0 ];then
        iommu='amd_iommu=on'
    else
        iommu='intel_iommu=on'
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "not config yet.
您还没有配置过该项" 10 60 
        chPassth
    else
    {
        sed -i 's/ '$iommu'//g' /etc/default/grub 
        echo 30
        update-grub 2>&1 &
        echo 80
        sed -i '/vfio/d' /etc/modules
        echo 100
        sleep 1
        }|whiptail --gauge "installing..." 10 60 10
        whiptail --title "Success" --msgbox "
need to reboot to apply! Please reboot.  
安装好后需要重启系统，请稍后重启。
        " 10 60
    fi
else
    main
fi
}

enVideo(){
    clear
    if [ `dmesg | grep -e DMAR -e IOMMU|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "
    Your hardware do not support PCI Passthrough(No IOMMU)
    您的硬件不支持直通！
    " 10 60
        configVideo
    fi
    if [ `grep 'iommu=on' /etc/default/grub|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    您的主机系统尚未配置直通支持，跳转去设置？
        " 10 60)then
            enablePass
        fi
    fi
    if [ `grep 'vfio' /etc/modules|wc -l` = 0 ];then
        if(whiptail --title "Warnning" --yesno "
    your host not enable IOMMU,jump to enable?
    您的主机系统尚未配置直通支持，跳转去设置？
        " 10 60)then
            enablePass
        fi
    fi
    getVideo

}

getVideo(){
    cards=`lspci |grep -e VGA`
    cards=`echo $cards |awk -F '.' '{print $1" " }'``echo $cards|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
    echo $cards > cards
    id=`cat /etc/modprobe.d/vfio.conf|grep -o "ids=[0-9a-zA-Z,:]*"|awk -F "=" '{print $2}'|sed  's/,/ /g'|sort -u`
    n=`for i in $id;do lspci -n -d $i|awk -F "." '{print $1}';done|sort -u` 
    for i in $n
    do
        cards=`sed -n '/'$i'/ s/OFF/ON/p' cards`
    done
    rm cards
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config(* mark means configed):
选择显卡（标*号为已经配置过的）：
" 15 90 4 \
$(echo $cards) \
3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            if(whiptail --title "Warnning" --yesno "
Continue?
请确认是否继续？
            " 10 60)then
                clear
            else
                getVideo 
            fi
            ids=""
            for i in $DISTROS
            do
                i=`echo $i|sed 's/\"//g'`
                ids=$ids`lspci -n -s ${i}|awk '{print ","$3}'`
            done
            ids=`echo $ids|sed 's/^,//g'|sed 's/ ,/,/g'`
            if [ `grep $ids'$' /etc/modprobe.d/vfio.conf|wc -l` = 0 ];then
                echo "options vfio-pci ids=$ids" > /etc/modprobe.d/vfio.conf
            else
                if(whiptail --defaultno --title "Warnning" --yesno "
    It seems you have already configed it before.Reconfig?
    您好像已经配置过这个了。重新配置？
                " 10 60)then
                    clear
                else
                   getVideo 
                fi
            fi
            #--config-blacklist--
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                if [ `grep '^blacklist '$i'$' /etc/modprobe.d/pve-blacklist.conf|wc -l` = 0 ];then
                    echo "blacklist "$i >> /etc/modprobe.d/pve-blacklist.conf
                fi
            done
            #--iommu-groups--
            if [ `find /sys/kernel/iommu_groups/ -type l|wc -l` = 0 ];then
                if [ `grep 'pcie_acs_override=downstream' /etc/default/grub|wc -l` = 0 ];then
                    sed -i.bak 's|iommu=on|iommu=on 'pcie_acs_override=downstream'|' /etc/default/grub
                    {
                    echo 50
                    update-grub 2>&1 &
                    echo 100
                    sleep 1
                    }|whiptail --gauge "installing..." 10 60 10
                fi
            fi
            #--video=efifb:off--
            if [ `grep 'video=efifb:off' /etc/default/grub|wc -l` = 0 ];then
                sed -i.bak 's|quiet|quiet video=efifb:off|' /etc/default/grub 
                update-grub
            fi
            #--kvm-parameters--
            if [ `cat /sys/module/kvm/parameters/ignore_msrs` = 'N' ];then
                echo 1 > /sys/module/kvm/parameters/ignore_msrs
                echo "options kvm ignore_msrs=Y">>/etc/modprobe.d/kvm.conf
            fi
            {
            echo 30
            update-initramfs -u -k all
            echo 100
            sleep 1
            }|whiptail --gauge "configing" 10 60 10
            whiptail --title "Success" --msgbox "
    need to reboot to apply! Please reboot.  
    安装好后需要重启系统，请稍后重启。
            " 10 60
        else
            if(whiptail --title "Warnning" --yesno "
Continue?
请确认是否继续？
            " 10 60)then
                clear
            else
                getVideo 
            fi
            {
            echo "" > /etc/modprobe.d/vfio.conf
            echo 0 > /sys/module/kvm/parameters/ignore_msrs
            sed -i '/ignore_msrs=Y/d' /etc/modprobe.d/kvm.conf
            for i in nvidiafb nouveau nvidia radeon amdgpu
            do
                sed -i '/'$i'/d' /etc/modprobe.d/pve-blacklist.conf 
            done
            echo 100
            sleep 1
            }|whiptail --gauge "configing..." 10 60 10
            whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
        fi
    else
        configVideo
    fi
}

disVideo(){
    clear
    getVideo dis
}
addVideo(){
    cards=`lspci |grep -e VGA`
    cards=`echo $cards |awk -F '.' '{print $1" " }'``echo $cards|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm` 
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.0.2 " --radiolist "
        Choose vmid to set video card Passthrough:
        选择需要配置显卡直通的vm：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        你选的是：$vmid ，是否继续?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            输入格式错误，请重新输入：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
您已经配置过这个了!
                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.0.2 " --checklist "
Choose options:
选择选项：" 20 60 10 \
                    "q35" "q35支持，gpu直通建议选择，独显留空" OFF \
                    "ovmf" "gpu直通选择" OFF \
                    "x-vga" "主gpu，默认已选择" ON \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
您已经配置过这个了!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
配置成功！重启虚拟机后生效。
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
是否自动帮你重启切换虚拟机？" 10 60)then
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                if [ $confId ];then
                                    usb=`cat /etc/pve/qemu-server/115.conf |grep '^usb'|wc -l`
                                    if [ $usb ];then
                                        if(whiptail --title "Yes/No" --yesno "
Let tool auto switch usb?
是否自动切换usb设备？
                                        " 10 60)then
                                            cat $confPath$confId.conf |grep '^usb'|sed 's/ //g'>usb
                                            sed -i '/^usb/d' $confPath$confId.conf
                                            for i in `cat usb`;do sed -i '/memory/a\'$i $confPath$vmid.conf;done
                                            sed -i 's/:host/: host/g' $confPath$vmid.conf
                                            rm usb
                                        fi
                                    fi
                                    qm stop $confId 
                                fi
                                {
                                qm stop $vmid 
                                echo 50
                                if [ $confId ];then
                                    qm start $confId 
                                fi
                                qm start $vmid
                                echo 100
                                sleep 1
                                }|whiptail --gauge "restarting vms" 10 60 10
                            whiptail --title "Success" --msgbox "
Configed!
配置成功！
                            " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
请选择一个显卡。" 10 60
            addVideo
        fi
    else
        configVideo
    fi
}
rmVideo(){
    clear
    vmid=$1
    confPath=$2
    DISTROS=$3
    for i in $vmid
    do
        sed -i '/q35/d' $confPath$vmid.conf
        for i in $DISTROS
            do
                if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` != 0 ];then
                    sed -i '/'$i'/d' $confPath$vmid.conf
                fi
            done
    done
}
switchVideo(){
    cards=`lspci |grep -e VGA`
    cards=`echo $cards |awk -F '.' '{print $1" " }'``echo $cards|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
    DISTROS=$(whiptail --title "Video cards:" --checklist \
"Choose cards to config?" 15 90 4 \
$(echo $cards) \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ];then
        #--config-id---
        if [ $DISTROS ];then
            confPath='/etc/pve/qemu-server/'
            ids=""
            for i in $DISTROS
            do

                i=`echo $i|sed 's/\"//g'`
                for j in `ls $confPath`
                do
                    if [ `grep $i $confPath$j|wc -l` != 0 ];then
                        confId=`echo $j|awk -F '.' '{print $1}'`
                    fi
                done
            done
            list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
            echo -n "">lsvm
            ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2" OFF"}'>>lsvm;done`
            ls=`sed -i '/'$confId'/ s/OFF/ON/g' lsvm` 
            ls=`cat lsvm`
            rm lsvm
            h=`echo $ls|wc -l`
            let h=$h*1
            if [ $h -lt 30 ];then
                h=30
            fi
            list1=`echo $list|awk 'NR>1{print $1}'`
            vmid=$(whiptail  --title " PveTools   Version : 2.0.2 " --radiolist "
        Choose vmid to set video card Passthrough:
        选择需要配置显卡直通的vm：" 20 60 10 \
            $(echo $ls) \
            3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                if(whiptail --title "Yes/No" --yesno "
        you choose: $vmid ,continue?
        你选的是：$vmid ，是否继续?
                    " 10 60)then
                    echo $vmid>vmid
                    while [ true ]
                    do
                        if [ `echo "$vmid"|grep "^[0-9]*$"|wc -l` = 0 ];then
                            whiptail --title "Warnning" --msgbox "
            输入格式错误，请重新输入：
                            " 10 60
                            addVideo
                        else
                            break
                        fi
                    done
                    if [ $vmid -eq $confId ];then
                        whiptail --title "Warnning" --msgbox "
You already configed!
您已经配置过这个了!
                        " 10 60
                        addVideo
                    fi
                    opt=$(whiptail  --title " PveTools   Version : 2.0.2 " --checklist "
Choose options:
选择选项：" 20 60 10 \
                    "q35" "q35支持，gpu直通建议选择，独显留空" OFF \
                    "ovmf" "gpu直通选择" OFF \
                    "x-vga" "主gpu，默认已选择" ON \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in 'boot:' 'memory:' 'core:';do
                            if [ `grep '^'$i $confPath$vmid.conf|wc -l` != 0 ];then
                                con=$i
                                break
                            fi
                        done
                        for op in $opt
                        do
                            op=`echo $op|sed 's/\"//g'`
                            if [ $op = 'q35' ];then
                                sed "/"$con"/a\machine\: q35" -i $confPath$vmid.conf
                            fi
                            if [ $op = 'ovmf' ];then
                                sed "/"$con"/a\bios\: ovmf" -i $confPath$vmid.conf
                            fi
                        done
                        #--config-vmid.conf---
                        for i in $DISTROS
                        do
                            if [ `cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|grep $i|wc -l` = 0 ];then
                                pcid=`cat $confPath$vmid.conf |sed  -n '/^hostpci/p'|awk -F ':' '{print $1}'|sort -u|grep '[0-9]*$' -o`
                                if [ $pcid ];then
                                    pcid=$((pcid+1))
                                else
                                    pcid=0
                                fi
                                i=`echo $i|sed 's/\"//g'`
                                sed -i "/"$con"/a\hostpci"$pcid": "$i",x-vga=1" $confPath$vmid.conf
                            else
                                whiptail --title "Warnning" --msgbox "
You already configed!
您已经配置过这个了!
                                " 10 60
                            fi
                            if [ $confId ];then
                                rmVideo $confId $confPath $i
                            fi
                            whiptail --title "Success" --msgbox "
Configed!Please reboot vm.
配置成功！重启虚拟机后生效。
                            " 10 60
                            if(whiptail --title "Yes/No" --yesno "
Let tool auto switch vm?
是否让工具自动帮你重启切换虚拟机？" 10 60)then
                                {
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                qm stop $confId 
                                qm stop $vmid 
                                echo 50
                                qm start $confId 
                                qm start $vmid
                                echo 100
                                sleep 1
                                }|whiptail --gauge "restarting vms" 10 60 10
                            whiptail --title "Success" --msgbox "
Configed!
配置成功！
                            " 10 60
                            else
                                configVideo
                            fi
                        done
                    else
                        addVideo
                    fi
                    configVideo
                else
                    addVideo
                fi
            else
                configVideo
            fi
        else
            whiptail --title "Warnning" --msgbox "
Please choose a card.
请选择一个显卡。" 10 60
            addVideo
        fi
    else
        configVideo
    fi
}

configVideo(){
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config PCI Video card Passthrough:" 25 60 15 \
    "a" "Config Video Card Passthrough" \
    "b" "Config Video Card Passthrough to vm" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置PCI显卡直通:" 25 60 15 \
    "a" "配置物理机显卡直通支持。" \
    "b" "配置显卡直通给虚拟机。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enVideo
        ;;
    b )
        addVideo
        ;;
    esac
else
    main
fi
}


#--------------funcs-end----------------

if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config PCI Passthrough:" 25 60 15 \
    "a" "Config IOMMU on." \
    "b" "Config IOMMU off." \
    "c" "Config Video Card Passthrough" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置硬件直通:" 25 60 15 \
    "a" "配置开启物理机硬件直通支持。" \
    "b" "配置关闭物理机硬件直通支持。" \
    "c" "配置显卡直通。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        enablePass
        ;;
    b )
        disablePass
        ;;
    c )
        configVideo
        ;;
    d )
        echo ""
    esac
else
    main
fi
}



chRoot(){
    #--base-funcs-start--
    setChroot(){
        clear
        if(whiptail --title "Yes/No" --yesno "
Continue?
是否继续？" --defaultno 10 60 )then
            if [ ! -f "/usr/bin/schroot" ];then
                whiptail --title "Warnning" --msgbox "you not installed schroot.
您还没有安装schroot。" 10 60
                if [ `ps aux|grep apt-get|wc -l` -gt 1 ];then
                    if(whiptail --title "Yes/No" --yesno "apt-get is running,killit and install schroot?
后台有apt-get正在运行，是否杀掉进行安装？
                    " 10 60);then
                        killall apt-get && apt-get -y install schroot
                    else
                        setChroot
                    fi
                else
                    apt-get -y install schroot
                fi
            fi
            sed '/^$/d' /etc/schroot/default/fstab
            if [ `grep '\/run\/udev' /etc/schroot/default/fstab|wc -l` = 0 ];then
                cat << EOF >> /etc/schroot/default/fstab
/run/udev       /run/udev       none    rw,bind         0       0 
EOF
            fi
            if [ `grep '\/sys\/fs\/cgroup' /etc/schroot/default/fstab|wc -l` = 0 ];then
                cat << EOF >> /etc/schroot/default/fstab
/sys/fs/cgroup  /sys/fs/cgroup  none    rw,rbind        0       0 
EOF
            fi
            sed -i '/\/home/d' /etc/schroot/default/fstab
            if [ ! -f "/etc/schroot/chroot.d/alpine.conf" ] || [ `cat /etc/schroot/chroot.d/alpine.conf|wc -l` -lt 8 ];then
                cat << EOF > /etc/schroot/chroot.d/alpine.conf
[alpine]
description=alpine 3.10.3
directory=/alpine
users=root
groups=root
root-users=root
root-groups=root
type=directory
shell=/bin/sh
EOF
            fi
            if [ ! -d "/alpine" ];then 
                mkdir /alpine 
            else
                clear
            fi
            cd /alpine
            if [ `ls /alpine|wc -l` -gt 0 ];then
                if(whiptail --title "Warnning" --yesno "files exist, remove and reinstall?
已经存在文件，是否清空重装？" --defaultno 10 60)then
                    killall dockerd
                    rm -rf /alpine/*
                fi
            fi
            wget -c --timeout 15 --waitretry 5 --tries 5 http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64/alpine-minirootfs-3.10.3-x86_64.tar.gz
            tar -xvzf alpine-minirootfs-3.10.3-x86_64.tar.gz
            rm -rf alpine-minirootfs-3.10.3-x86_64.tar.gz
            echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /alpine/etc/apk/repositories \
            && echo "http://mirrors.aliyun.com/alpine/latest-stable/community/"  >> /alpine/etc/apk/repositories
            cat << EOF >> /alpine/etc/profile
echo "Welcome to alpine chroot."
echo "Create by PveTools."
echo "Author: 龙天ivan"
echo "Github: https://github.com/ivanhao/pvetoools"
EOF
            schroot -c alpine apk update
            whiptail --title "Success" --msgbox "Done.
安装配置完成！" 10 60
            chRoot
        else
            chRoot
        fi
    }
    installOs(){
        clear
    }
    enterChroot(){
        clear
        checkSchroot
        c=`schroot -l|awk -F ":" '{print $2"  "$1}'`
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Enter chroot:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "进入chroot环境:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            if [ $x ];then
                schroot -c $x -d /root
            else
                chRoot
            fi
            chRoot
        fi
    }
    docker(){
        clear
        checkSchroot
        if [ `schroot -c alpine -d /root ls /usr/bin|grep docker|wc -l` = 0 ];then
            if(whiptail --title "Warnning" --yesno "No docker found.Install?
您还没有安装docker,是否安装？" 10 60)then
                schroot -c alpine -d /root apk update
                schroot -c alpine -d /root apk add docker
                cat << EOF >> /alpine/etc/profile
export DOCKER_RAMDISK=true
echo "Docker installed."
nohup /usr/bin/dockerd > /dev/null 2>&1 &
EOF
                configChroot
            fi
        else
                schroot -c alpine -d /root 
        fi
        configChroot
    }
    checkSchroot(){
        if [ `ls /usr/bin|grep schroot|wc -l` = 0 ] || [ `schroot -l|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No schroot found.Install schroot first.
您还没有安装schroot环境，请先安装。" 10 60 
            chRoot
        fi
    }
    configChroot(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config chroot & docker etc:" 25 60 15 \
            "a" "Config base schroot." \
            "c" "Docker in alpine" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置chroot环境和docker等:" 25 60 15 \
            "a" "配置基本的chroot环境（schroot 默认为alpine)。" \
            "c" "Docker（alpine）。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                setChroot
                ;;
            c )
                docker
                #whiptail --title "Warnning" --msgbox "Not supported." 10 60
                chroot
            esac
        else
            chRoot
        fi
    }
    #--base-funcs-end--
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "Config chroot & docker etc:" 25 60 15 \
    "a" "Install & config base schroot." \
    "b" "Enter chroot." \
    "c" "Remove all chroot." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "配置chroot环境和docker等:" 25 60 15 \
    "a" "安装配置基本的chroot环境（schroot 默认为alpine)。" \
    "b" "进入chroot。" \
    "c" "彻底删除chroot。" \
    3>&1 1>&2 2>&3)
fi
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$x" in
    a )
        configChroot
        ;;
    b )
        enterChroot
        ;;
    c )
        checkSchroot
        apt-get -y autoremove schroot debootstrap
        if [ -d "/alpine/sys/fs/cgroup" ];then
            mount --make-rslave /alpine/sys/fs/cgroup
            umount -R /alpine/sys/fs/cgroup
        fi
        killall dockerd
        rm -rf /alpine
        whiptail --title "Success" --msgbox "Done.
删除成功" 10 60

esac
fi

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
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "
Github: https://github.com/ivanhao/pvetools
Please choose:" 25 60 15 \
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
    "m" "Config chroot & docker etc." \
    "u" "Upgrade this script to new version." \
    "L" "Change Language." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.0.2 " --menu "
Github: https://github.com/ivanhao/pvetools
请选择相应的配置：" 25 60 15 \
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
    "m" "配置chroot环境和docker等" \
    "u" "升级该pvetools脚本到最新版本" \
    "L" "Change Language" \
    3>&1 1>&2 2>&3)
fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$OPTION" in
        a )
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
        b )
            chSource
            main
            ;;
        c )
            chSamba
            main
            ;;
        d )
            chMail
            main
            ;;
        e )
            chZfs
            main
            ;;
        f )
            chVim
            main
            ;;
        g )
            chCpu
            main
            ;;
        h )
            chSpindown
            main
            ;;
        i )
            #echo "not support yet."
            chPassth
            main
            ;;
        j )
            chSensors
            sleep 2
            main
            ;;
        k )
            clear
            chNestedV
            main
            ;;
        l )
            chSubs
            main
            ;;
        m )
            chRoot
            main
            ;;

        u )
            {
            echo 50
            sleep 1
            echo 100
            $(
            git pull && ./pvetools.sh
            )
            } |whiptail --gauge "updating when 100% type enter. 进度条满后回车" 10 60 0
            ;;
        L )
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
