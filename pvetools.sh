#!/bin/bash
#############--Proxmox VE Tools--##########################
#  Author : 龙天ivan
#  Mail: ivanhao1984@qq.com
#  Version: v2.3.3
#  Github: https://github.com/ivanhao/pvetools
########################################################

#js whiptail --title "Success" --msgbox "c" 10 60
if [ `export|grep 'LC_ALL'|wc -l` = 0 ];then
    if [ `grep "LC_ALL" /etc/profile|wc -l` = 0 ];then
        echo "export LC_ALL='en_US.UTF-8'" >> /etc/profile
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
    apt -y install mailutils
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
            whiptail --title "Warnning" --msgbox "
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
currentDebianVersion=${sver}
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
    11 )
        sver="bullseye"
        ;;
    * )
        sver=""
esac
if [ ! $sver ];then
    whiptail --title "Warnning" --msgbox "Not supported!
    您的版本不支持！无法继续。" 10 60
    main
fi
# debian 11 change security source rule
if [ $currentDebianVersion -gt 10 ];then
    securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ stable-security main contrib non-free
"
else
    securitySource="
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free
"
fi
    #"a" "Automation mode." \
    #"a" "无脑模式" \
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config apt source:" 25 60 15 \
    "b" "Change to cn source." \
    "c" "Disable enterprise." \
    "d" "Undo Change." \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置apt镜像源:" 25 60 15 \
    "b" "更换为国内源" \
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
            cat > /etc/apt/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free
$securitySource
EOF
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
        if [ $L = "en" ];then
            OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config apt source:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "Main menu." \
            3>&1 1>&2 2>&3)
        else
            OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置apt镜像源:" 25 60 15 \
            "a" "aliyun.com" \
            "b" "ustc.edu.cn" \
            "q" "返回主菜单" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$OPTION" in
                a )
                    ss="aliyun.com"
                    ;;
                b)
                    ss="ustc.edu.cn"
                    ;;
                q )
                    chSource
            esac
            if (whiptail --title "Yes/No Box" --yesno "修改更新源为$ss?" 10 60) then
                if [ `grep $ss /etc/apt/sources.list|wc -l` = 0 ];then
                    cp /etc/apt/sources.list /etc/apt/sources.list.bak
                    #cp /etc/apt/sources.list.d/ceph.list /etc/apt/sources.list.d/ceph.list.bak
                    #sver=`cat /etc/apt/sources.list|awk 'NR==1{print $3}'`
                    cat > /etc/apt/sources.list << EOF
deb https://mirrors.$ss/debian/ $sver main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver main contrib non-free
deb https://mirrors.$ss/debian/ $sver-updates main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver-updates main contrib non-free
deb https://mirrors.$ss/debian/ $sver-backports main contrib non-free
deb-src https://mirrors.$ss/debian/ $sver-backports main contrib non-free
$securitySource
EOF
                    #修改 ceph镜像更新源
                    #echo "deb http://mirrors.$ss/proxmox/debian/ceph-luminous $sver main" > /etc/apt/sources.list.d/ceph.list
                    #修改pve 更新源地址为非订阅更新源，不使用企业订阅更新源。
                    echo "deb http://mirrors.ustc.edu.cn/proxmox/debian/pve/ $sver pve-no-subscription" > /etc/apt/sources.list.d/pve-no-sub.list
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    软件源已更换成功！" 10 60
                    apt-get update
                    apt-get -y install net-tools
                    whiptail --title "Success" --msgbox " apt source has been changed successfully!
                    软件源已更换成功！" 10 60
                else
                    whiptail --title "Success" --msgbox " Already changed apt source to $ss!
已经更换apt源为 $ss" 10 60
                fi
            else
                chSource
            fi
            chSource
        else
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
    #cp /etc/apt/sources.list.d/ceph.list.bak /etc/apt/sources.list.d/ceph.list
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
            if [ `echo $qqmail|grep '^[a-zA-Z0-9\_\-\.]*\@[A-Za-z0-9\_\-\.]*\.[a-zA-Z\_\-\.]*$'` ];then
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
            apt -y install mailutils
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
    x=$(whiptail --title "Config ZFS" --inputbox "
set max zfs ram 4(G) or 8(G) etc, just enter number or n?
设置最大zfs内存（zfs_arc_max),比如4(G)或8(G)等, 只需要输入纯数字即可，比如4G输入4?
    " 20 60    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ "$x" =~ ^[1-9]+$ ]]; then
                    update-initramfs -u
                {
                    $(echo "options zfs zfs_arc_max=$[$x*1024*1024*1024]">/etc/modprobe.d/zfs.conf)
                    echo 10
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
            if [ `dpkg -l|grep zfs-zed|wc -l` = 0 ];then
                apt-get -y install zfs-zed
            fi
            whiptail --title "Success" --msgbox "
    Install complete!
    安装zfs-zed成功！
            " 10 60
        else
            chZfs
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
        addSmbRecycle(){
            if(whiptail --title "Yes/No" --yesno "enable recycle?
开启回收站？" 10 60 )then
                if [ ! -f '/etc/samba/smb.conf' ];then
                    whiptail --title "Warnning" --msgbox "You should install samba first!
    请先安装samba！" 10 60
                else
                    if [ `sed -n "/\[$2\]/,/$2 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                        whiptail --title "Warnning" --msgbox "Already configed!  已经配置过了。" 10 60
                        smbRecycle
                    else
                        cat << EOF > ./recycle
# $2--recycle-start--
vfs object = recycle
recycle:repository = $1/.deleted
recycle:keeptree = Yes
recycle:versions = Yes
recycle:maxsixe = 0
recycle:exclude = *.tmp
# $2--recycle-end--
EOF
                        #n=`sed '/\['$2'\]/' /etc/samba/smb.conf -n|sed -n '$p'`
                        cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                        sed -i '/\['$2'\]/r ./recycle' /etc/samba/smb.conf
                        rm ./recycle
#                        cat << EOF >> /etc/samba/smb.conf
#[$2-recycle]
#comment = All
#browseable = yes
#path = $1/.deleted
#guest ok = no
#read only = no
#create mask = 0750
#directory mask = 0750
#;  $2-recycle end
#EOF
                        systemctl restart smbd
                        whiptail --title "Success" --msgbox "Done.
    配置完成" 10 60
                    fi
                fi
            else
                continue
            fi
        }
        delSmbRecycle(){
            if [ ! -f '/etc/samba/smb.conf' ];then
                whiptail --title "Warnning" --msgbox "You should install samba first!
请先安装samba！" 10 60
            else
                if [ `sed -n "/\[$1\]/,/$1 end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` = 0 ];then
                    whiptail --title "Warnning" --msgbox "Already configed!  已经配置过了。" 10 60
                    smbRecycle
                else
                    cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
                    sed -i '/.*'$1'.*recycle.*start/,/.*'$1'.*end/d' /etc/samba/smb.conf
                    sed "/\[${1}\-recycle\]/,/${n}\-recycle end/d" /etc/samba/smb.conf -i
                    systemctl restart smbd
                    whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                fi
            fi
        }

clear
#$(grep -E "^\[[0-9a-zA-Z.-]*\]$|^path" /etc/samba/smb.conf|awk 'NR>3{print $0}'|sed 's/path/        path/'|grep -v '-recycle')
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config samba:" 25 60 15 \
    "a" "Install samba and config user." \
    "b" "Add folder to share." \
    "c" "Delete folder to share." \
    "d" "Config recycle" \
    "q" "Main menu." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置samba:" 25 60 15 \
    "a" "安装配置samba并配置好samba用户" \
    "b" "添加共享文件夹" \
    "c" "取消共享文件夹" \
    "d" "配置回收站" \
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
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
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
            oldgrp=`ls -l $x|awk 'NR==2{print $4}'`
            if [ `grep "${x}$" /etc/samba/smb.conf|wc -l` = 0 ];then
                cat << EOF >> /etc/samba/smb.conf
[$n]
comment = All
browseable = yes
path = $x
guest ok = no
read only = no
create mask = 0750
directory mask = 0750
; oldgrp $oldgrp
;  $n end
EOF
                whiptail --title "Success" --msgbox "
Configed!
配置成功！
                " 10 60
                #--2.3.3 add group
                chgrp -R samba $x
                chmod -R g+w $x
                addSmbRecycle $x $n
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
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
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
                oldgrp=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf |grep oldgrp|awk '{print $3}'`
                x=`grep -E "^path = [0-9a-zA-Z/-.]*${n}" /etc/samba/smb.conf|awk '{print $3}'`
                if [ $oldgrp ];then
                    chgrp -R $oldgrp $x
                fi
                sed "/\[${n}\]/,/${n} end/d" /etc/samba/smb.conf -i
                sed "/\[${n}-recycle\]/,/${n}-recycle end/d" /etc/samba/smb.conf -i
                whiptail --title "Success" --msgbox "
Configed!
配置成功！
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
    d )
        smbRecycle(){
            if [ $L = "en" ];then
                x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config samba recycle:" 12 60 4 \
                "a" "Enable samba recycle." \
                "b" "Disable samba recycle." \
                "c" "Clear recycle." \
                3>&1 1>&2 2>&3)
            else
                x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置samba回收站！" 12 60 4 \
                "a" "开启samba回收站。" \
                "b" "关闭samba回收站。" \
                "c" "清空samba回收站。" \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                case "$x" in
                    a )
                        enSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
已有的共享目录：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
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
                                    enSmbRecycle
                                done
                                if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                    if [ `sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|egrep '^recycle'|wc -l` != 0 ];then
                                        whiptail --title "Warnning" --msgbox "Already configed!  已经配置过了。" 10 60
                                        smbRecycle
                                    else
                                        x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                        addSmbRecycle $x $n
                                        service smbd restart
                                    fi
                                fi
                                disSmbRecycle
                            else
                                smbRecycle
                            fi
                        }
                        enSmbRecycle
                        ;;
                    b )
                        disSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Remove Samba recycle" --inputbox "
Exist share folders:
已有的共享目录：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
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
                                    disSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls $x/.deleted/|wc -l` != 0 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty, you should clear it first.continue?
回收站中存在文件，建议先清空，是否确认要继续？" 10 60);then
                                        if [ `grep "^\[${n}\]$" /etc/samba/smb.conf|wc -l` != 0 ];then
                                            delSmbRecycle $n
                                            service smbd restart
                                        fi
                                        disSmbRecycle
                                    else
                                        disSmbRecycle
                                    fi
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        disSmbRecycle
                        ;;
                    c )
                        checkClearSmb(){
                            c=$(whiptail --title "Clear Samba recycle" --inputbox "
you can disable recycle to clear it.
clear recycle may cause data lose,pvetools will not response for that,do you agree?
type 'YesIdo' to continue:
你可以先取消回收站再手工清空。
工具清空samba回收站不可逆，pvetools不会对此操作负责，是否同意？
如果确认要清空，请输入'YesIdo'继续：" 20 60 "" 3>&1 1>&2 2>&3)
                            exitstatus=$?
                            if [ $exitstatus = 0 ]; then
                                while [ $c != 'YesIdo' ]
                                do
                                    whiptail --title "Success" --msgbox "
Woring words,try again:
输入错误，请重试:
                                    " 10 60
                                    checkClearSmb
                                done
                            else
                                continue
                            fi
                        }
                        clearSmbRecycle(){
                            h=`grep "^\[[0-9a-zA-Z.-]*\]$" /etc/samba/smb.conf|awk 'NR>3{print $0}'|wc -l`
                            if [ $h -lt 3 ];then
                                let h=$h*15
                            else
                                let h=$h*5
                            fi
                            n=$(whiptail --title "Clear Samba recycle" --inputbox "
Exist share folders:
已有的共享目录：
----------------------------------------
$(grep -Ev "-recycle|.deleted$" /etc/samba/smb.conf|grep -E "^\[[0-9a-zA-Z.-]*\]$|^path"|sed 's/path/        path/'|awk 'NR>3{print $0}')
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
                                    clearSmbRecycle
                                done
                                x=`sed -n "/\[${n}\]/,/${n} end/p" /etc/samba/smb.conf|grep path|awk '{print $3}'`
                                if [ `ls -a $x/.deleted/|wc -l` -gt 2 ];then
                                    if(whiptail --title "Warnning" --yesno "recycle not empty,continue?
回收站中存在文件，是否确认要继续？" 10 60);then
                                        checkClearSmb
                                        rm -rf $x/.deleted/*
                                        rm -rf $x/.deleted/.*
                                        whiptail --title "Success" --msgbox "ok." 10 60
                                    else
                                        clearSmbRecycle
                                    fi
                                else
                                    whiptail --title "Success" --msgbox "Already empty.回收站是空的，不需要清空。" 10 60
                                fi
                            else
                                smbRecycle
                            fi
                        }
                        clearSmbRecycle
                        ;;
                esac
            else
                chSamba
            fi
        }
        smbRecycle
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
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config VIM:" 12 60 4 \
    "a" "Install vim & simply config display." \
    "b" "Install vim & config 'vim-for-server'." \
    "c" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "安装配置VIM！" 12 60 4 \
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
            if [ ! -f /root/.vimrc ] || [ `cat /root/.vimrc|wc -l` = 0 ] || [ `dpkg -l |grep vim|wc -l` = 0 ];then
                apt -y install vim
            else
                cp ~/.vimrc ~/.vimrc.bak
            fi
            {
            echo 10
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
            echo "Use curl or git? If one not work,change to another."
            echo "选择git或curl，如果一个方式不行可以换一个。"
            echo "1 ) git"
            echo "2 ) curl"
            echo "Please choose:"
            read x
            case $x in
                2 )
                    apt -y install curl vim
                    cp ~/.vimrc ~/.vimrc_bak
                    curl https://raw.githubusercontent.com/wklken/vim-for-server/master/vimrc > ~/.vimrc
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            安装配置完成！
                    " 10 60
                    ;;
                1 | "" )
                    apt -y install git vim
                    rm -rf vim-for-server
                    git clone https://github.com/wklken/vim-for-server.git
                    mv ~/.vimrc ~/.vimrc_bak
                    mv vim-for-server/vimrc ~/.vimrc
                    rm -rf vim-for-server
                    whiptail --title "Success" --msgbox "
            Install & config complete!
            安装配置完成！
                    " 10 60
                    ;;
                * )
                    chVim
            esac

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
        if [ `dpkg -l|grep git|wc -l` = 0 ];then
            apt -y install git
        fi
        cd /root
        git clone https://github.com/ivanhao/hdspindown.git
    {
        echo 10
        echo 50
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
chApm(){
    clear
    apm=$(
    whiptail --title " PveTools   Version : 2.3.3 " --menu "Config hard disks APM & AAM:
配置硬盘静音、降温：
    " 25 60 15 \
    "128" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
}

if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config hard disks spindown:" 25 60 15 \
    "a" "Config hard drivers to auto spindown." \
    "b" "Remove config hdspindown." \
    "c" "Config pvestatd service(in case of spinup drives)." \
    "d" "Config drivers aam\apm to low temp and quiet." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置硬盘自动休眠" 25 60 15 \
    "a" "配置硬盘自动休眠" \
    "b" "还原硬盘自动休眠配置" \
    "c" "配置pvestatd服务（防止休眠后马上被唤醒）。" \
    "d" "设置硬盘静音、降温" \
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
    x=$(whiptail --title "Max cpufrequtils最大频率" --inputbox "
$info
--------------------------------------------
Input MAX_SPEED(example: 1.6GHz type 1600000):
输入最大频率（示例：1.6GHz 输入1600000）：
    " 20 60  3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
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
    x=$(whiptail --title "Mini cpufrequtils最小频率" --inputbox "
$info
--------------------------------------------
Input MIN_SPEED(example: 1.6GHz type 1600000):
输入最小频率（示例：1.6GHz 输入1600000）：
    " 20 60   3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [[ `echo "$x"|grep "^[0-9]*$"|wc -l` = 0 ]] || [[ $x = "" ]];then
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
    apt -y install cpufrequtils
    if [ `grep "intel_pstate=disable" /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet intel_pstate=disable|' /etc/default/grub
        update-grub
    fi
    cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="conservative"
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
doChCpu1(){
if(whiptail --title "Yes/No Box" --yesno "
continue?
开始配置?
" --defaultno 10 60) then
    cpufreq-info|grep -E "available|analyzing CPU|current"|sed -n "/analyz/,/analyz/p"|sed '$d'
    maxCpu
    minCpu
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="performance"
MAX_SPEED="$mx"
MIN_SPEED="$mi"
EOF
    systemctl restart cpufrequtils
    whiptail --title "Success" --msgbox "
Done
配置完成
    " 10 60
else
    main
fi
}
#-------------chCpu--main---------------
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Config cpufrequtils to save power." \
    "b" "Remove config." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "安装配置CPU省电" 25 60 15 \
    "a" "安装配置CPU省电(动态调整)" \
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
    c )
        if(whiptail --title "Yes/No" --yesno "
continue?
还原配置？
        " --defaultno 10 60 ) then
            #sed -i 's/ intel_pstate=disable//g' /etc/default/grub
            #rm -rf /etc/default/cpufrequtils
    cat << EOF > /etc/default/cpufrequtils
ENABLE="true"
GOVERNOR="ondemand"
EOF
            systemctl restart cpufrequtils
            if (whiptail --title "Yes/No" --yesno "
Uninstall cpufrequtils?
卸载cpufrequtils?
                " 10 60 ) then
                apt -y remove cpufrequtils 2>&1 &
                sed -i 's/ intel_pstate=disable//g' /etc/default/grub
                rm -rf /etc/default/cpufrequtils
            fi
            whiptail --title "Success" --msgbox "
Done
配置完成
            " 10 60
        fi
        chCpu
        ;;
    b )
        doChCpu1
        ;;
    esac
fi
#-------------chCpu--main--end------------

}

chSubs(){
clear
if [ $L = "en" ];then
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config Cpufrequtils:" 25 60 15 \
    "a" "Remove subscribe notice." \
    "b" "Unset config." \
    "c" "fix proxmox-widget-toolkit" \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "安装配置CPU省电" 25 60 15 \
    "a" "去除订阅提示" \
    "b" "还原配置" \
    "c" "修复去除订阅失败" \
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
            #whiptail --title " in " --msgbox "$bver $cver  $dver" 10 60
            if [ `grep "data.status.toLowerCase() !== 'active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` -gt 0 ];then
                sed -i.bak "s/data.status.toLowerCase() !== 'active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
去除成功！
                " 10 60
            elif [ `grep "data.status !== 'Active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` -gt 0 ];then
                sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
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
                systemctl restart pveproxy
                whiptail --title "Success" --msgbox "
Done!!
还原成功！
                " 10 60
            elif [ `grep "data.status.toLowerCase() !== 'active'" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js|wc -l` = 0 ];then
                mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
                systemctl restart pveproxy
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
    c )
        if(whiptail --title "Yes/No" --yesno "
continue?
是否修复订阅提示?
            " 10 60) then
            apt install --reinstall proxmox-widget-toolkit
            whiptail --title "Success" --msgbox "
Done!!
还原成功！
                " 10 60
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
    vmid=$(whiptail  --title " PveTools   Version : 2.3.3 " --menu "
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
    vmid=$(whiptail  --title " PveTools   Version : 2.3.3 " --menu "
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
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config Nested:" 25 60 15 \
    "a" "Enable nested" \
    "b" "Set vm to nested" \
    "c" "Unset vm nested" \
    "d" "Disable nested" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置嵌套虚拟化:" 25 60 15 \
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
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config lm-sensors & proxmox ve display:" 25 60 15 \
    "a" "Install." \
    "b" "Uninstall." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置Sensors:" 25 60 15 \
    "a" "安装配置温度、CPU频率显示" \
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
            mkdir /etc/pvetools/
            if [ ! -f $js ];then
                cp $js /etc/pvetools/pvemanagerlib.js
            fi
            if [ ! -f $pm ];then
                cp $pm /etc/pvetools/Nodes.pm
            fi
            if [[ "$OS" != "pve" ]];then
                whiptail --title "Warnning" --msgbox "
您的系统不是Proxmox VE, 无法安装!
Your OS is not Proxmox VE!
                " 10 60
                if [[ "$bver" != "5" || "$bver" != "6" || "$bver" != "7" ]];then
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
            #if [[ -f "$js.backup" && -f "$sh" ]];then
            if [[ `cat $js|grep Sensors|wc -l` -gt 0 ]];then
                whiptail --title "Warnning" --msgbox "
您已经安装过本软件，请不要重复安装！
You already installed,Now quit!
                " 10 60
                chSensors
            fi
            if [ ! -f "/usr/bin/sensors" ];then
                apt-get -y install lm-sensors
            fi
            sensors-detect --auto > /tmp/sensors
            drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
            if [ `echo $drivers|wc -w` = 0 ];then
                whiptail --title "Warnning" --msgbox "
Sensors driver not found.
没有找到任何驱动，似乎你的系统没有温度传感器。
继续配置CPU频率...
                " 10 60
                cat << EOF > /usr/bin/s.sh
c=\`lscpu|grep MHz|sed 's/CPU\ /CPU-/g'|sed 's/\ MHz/-MHz/g'|sed 's/\ //g'|sed 's/^/"/g'|sed 's/$/"\,/g'|sed 's/\:/\"\:\"/g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'\`
r="{"\$c"}"
echo \$r
EOF
            chmod +x /usr/bin/s.sh
            #--create the configs--
            if [ -f ./p1 ];then rm ./p1;fi
            #--这里插入cpu频率　add cpu MHz--
            cat << EOF >> ./p1
             ,{
             itemId: 'MHz',
             colspan: 2,
             printBar: false,
             title: gettext('CPU频率'),
             textField: 'tdata',
             renderer:function(value){
                 var d = JSON.parse(value);
                 f0 = d['CPU-MHz'];
                 f1 = d['CPU-min-MHz'];
                 f2 = d['CPU-max-MHz'];
                 return  \`CPU实时(Cur): \${f0} MHz | 最小(min): \${f1} MHz | 最大(max): \${f2} MHz \`;
         }
 }
EOF
            #--插入cpu频率结束　add cpu MHz end--
            cat << EOF >> ./p2
\$res->{tdata} = \`/usr/bin/s.sh\`;
EOF
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

                chSensors
            else
                for i in $drivers
                do
                    modprobe $i
                    if [ `grep $i /etc/modules|wc -l` = 0 ];then
                        echo $i >> /etc/modules
                    fi
                done
                sensors
                sleep 3
                whiptail --title "Success" --msgbox "
Install complete,if everything ok ,it\'s showed sensors.Next, restart you web.
安装配置成功，如果没有意外，上面已经显示sensors。下一步会重启web界面，请不要惊慌。
                " 20 60
            rm /tmp/sensors
            cat << EOF > /usr/bin/s.sh
r=\`sensors|grep -E 'Package id 0|fan|Physical id 0|Core'|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'|sed 's/°C/C/g'\`
c=\`lscpu|grep MHz|sed 's/CPU\ /CPU-/g'|sed 's/\ MHz/-MHz/g'|sed 's/\ //g'|sed 's/^/"/g'|sed 's/$/"\,/g'|sed 's/\:/\"\:\"/g'|awk 'BEGIN{ORS=""}{print \$0}'|sed 's/\,\$//g'\`
r="{"\$r","\$c"}"
echo \$r
EOF
            chmod +x /usr/bin/s.sh
            #--create the configs--
            #--filter for sensors 过滤sensors项目--
            d=`sensors|grep -E 'Package id 0|fan|Physical id 0|Core'|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk -F ":" '{print $1}'`
            if [ -f ./p1 ];then rm ./p1;fi
            #--这里插入cpu频率　add cpu MHz--
            cat << EOF >> ./p1
             ,{
             itemId: 'MHz',
             colspan: 2,
             printBar: false,
             title: gettext('CPU频率'),
             textField: 'tdata',
             renderer:function(value){
                 var d = JSON.parse(value);
                 f0 = d['CPU-MHz'];
                 f1 = d['CPU-min-MHz'];
                 f2 = d['CPU-max-MHz'];
                 return  \`CPU实时(Cur): \${f0} MHz | 最小(min): \${f1} MHz | 最大(max): \${f2} MHz \`;
         }
 }
EOF
            #--插入cpu频率结束　add cpu MHz end--
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
#\$res->{cpusensors} = \`lscpu | grep MHz\`;
            #--configs end--
            #h=`sensors|awk 'END{print NR}'`
            itemC=`s.sh|sed  's/\,/\r\n/g'|wc -l`
            if [ $itemC = 0 ];then
                h=400
            else
                #let h=$h*9+320
                let h=$itemC*24/2+360
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
        fi
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

            if [[ `cat $js|grep -E 'Sensors|CPU'|wc -l` = 0 ]];then
                whiptail --title "Warnning" --msgbox "
No sensors found.
没有检测到安装，不需要卸载。
                " 10 60
            else
                sensors-detect --auto > /tmp/sensors
                drivers=`sed -n '/Chip drivers/,/\#----cut here/p' /tmp/sensors|sed '/Chip /d'|sed '/cut/d'`
                if [ `echo $drivers|wc -w` != 0 ];then
                    for i in $drivers
                    do
                        if [ `grep $i /etc/modules|wc -l` != 0 ];then
                            sed -i '/'$i'/d' /etc/modules
                        fi
                    done
                fi
                apt-get -y remove lm-sensors
            {
                #mv $js.backup $js
                #mv $pm.backup $pm
                rm $js
                rm $pm
                rm /usr/bin/s.sh
                cp /etc/pvetools/pvemanagerlib.js $js
                cp /etc/pvetools/Nodes.pm $pm
                echo 50
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
    ppv=`/usr/bin/pveversion`
    OS=`echo $ppv|awk -F'-' 'NR==1{print $1}'`
    ver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'-' '{print $1}'`
    bver=`echo $ppv|awk -F'/' 'NR==1{print $2}'|awk -F'.' '{print $1}'`
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
        iommu="amd_iommu=on"
    else
        iommu="intel_iommu=on"
    fi
    if [ ${bver} -gt 6 ];then
        iommu=$iommu" iommu=pt pcie_acs_override=downstream"
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        sed -i.bak 's|quiet|quiet '$iommu'|' /etc/default/grub
        update-grub
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
    if [ `cat /proc/cpuinfo|grep Intel|wc -l` = 0 ];then
        iommu='amd_iommu=on'
    else
        iommu='intel_iommu=on'
    fi
    if [ `grep $iommu /etc/default/grub|wc -l` = 0 ];then
        whiptail --title "Warnning" --msgbox "not config yet.
您还没有配置过该项" 10 60
        chPassth
    else
        update-grub
    {
        sed -i 's/ '$iommu'//g' /etc/default/grub
        echo 30
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
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -E 'VGA|Audio' > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cat cards-out > cards
    id=`cat /etc/modprobe.d/vfio.conf|grep -o "ids=[0-9a-zA-Z,:]*"|awk -F "=" '{print $2}'|sed  's/,/ /g'|sort -u`
    n=`for i in $id;do lspci -n -d $i|awk -F "." '{print $1}';done|sort -u`
    for i in $n
    do
        cards=`sed -n '/'$i'/ s/OFF/ON/p' cards`
    done
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
	    rm cards*
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
                    sed -i.bak 's|iommu=on|iommu=on 'iommu=pt pcie_acs_override=downstream'|' /etc/default/grub
                    update-grub
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
            update-initramfs -u -k all
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
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
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
            vmid=$(whiptail  --title " PveTools   Version : 2.3.3 " --radiolist "
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
                    opt=$(whiptail  --title " PveTools   Version : 2.3.3 " --checklist "
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
                                qm stop $vmid
                                if [ $confId ];then
                                    qm start $confId
                                fi
                                qm start $vmid
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
    if [ -f "cards" ];then
        rm cards
    fi
    if [ -f "cards-out" ];then
        rm cards-out
    fi
    lspci |grep -e VGA > cards
    cat cards|while read line
    do
        c=`echo $line |awk -F '.' '{print $1" " }'``echo $line|awk -F ': ' '{for (i=2;i<=NF;i++)printf("%s_", $i);print ""}'|sed 's/ /_/g'``echo ' OFF'`
        echo $c >> cards-out
    done
    cards=`cat cards-out`
    rm cards*
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
            vmid=$(whiptail  --title " PveTools   Version : 2.3.3 " --radiolist "
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
                    opt=$(whiptail  --title " PveTools   Version : 2.3.3 " --checklist "
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
                                #vmid=`echo $vmid|sed 's/\"//g'`
                                vmid=`cat vmid`
                                rm vmid
                                qm stop $confId
                                qm stop $vmid
                                qm start $confId
                                qm start $vmid
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
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config PCI Video card Passthrough:" 25 60 15 \
    "a" "Config Video Card Passthrough" \
    "b" "Config Video Card Passthrough to vm" \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置PCI显卡直通:" 25 60 15 \
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
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config PCI Passthrough:" 25 60 15 \
    "a" "Config IOMMU on." \
    "b" "Config IOMMU off." \
    "c" "Config Video Card Passthrough" \
    "d" "Config qm set disks." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置硬件直通:" 25 60 15 \
    "a" "配置开启物理机硬件直通支持。" \
    "b" "配置关闭物理机硬件直通支持。" \
    "c" "配置显卡直通。" \
    "d" "配置qm set 硬盘给虚拟机。" \
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
        chQmdisk
    esac
else
    main
fi
}

checkPath(){
    x=$(whiptail --title "Choose a path" --inputbox "
Input path:
请输入路径：" 10 60 \
    $1 \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        while [ true ]
        do
            if [ ! -d $x ];then
                whiptail --title "Warnning" --msgbox "Path not found.
没有检测到路径，请重新输入" 10 60
                checkPath
            else
                break
            fi
        done
        echo $x
        return $?
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
                sed '/cgroup/d' /etc/schroot/default/fstab
                cat << EOF >> /etc/schroot/default/fstab
/sys/fs/cgroup  /sys/fs/cgroup  none    rw,rbind        0       0
EOF
            fi
            sed -i '/\/home/d' /etc/schroot/default/fstab
            checkPath /
            chrootp=${x%/}"/alpine"
            echo $chrootp > /etc/schroot/chrootp
            if [ ! -d $chrootp ];then
                mkdir $chrootp
            else
                clear
            fi
            cd $chrootp
            if [ `ls $chrootp/bin|wc -l` -gt 0 ];then
                if(whiptail --title "Warnning" --yesno "files exist, remove and reinstall?
已经存在文件，是否清空重装？" --defaultno 10 60)then
                    for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                    killall dockerd
                    killall portainer
                    rm -rf $chrootp/*
                else
                    configChroot
                fi
            fi
            if [ $L = "en" ];then
                alpineUrl='http://dl-cdn.alpinelinux.org/alpine/v3.10/releases/x86_64'
            else
                alpineUrl='https://mirrors.aliyun.com/alpine/v3.10/releases/x86_64'
            fi
            version=`wget $alpineUrl/ -q -O -|grep minirootfs|grep -o '[0-9]*\.[0-9]*\.[0-9]*'|sort -u -r|awk 'NR==1{print $1}'`
            echo $alpineUrl
            echo $version
            sleep 3
            wget -c --timeout 15 --waitretry 5 --tries 5 $alpineUrl/alpine-minirootfs-$version-x86_64.tar.gz
            tar -xvzf alpine-minirootfs-$version-x86_64.tar.gz
            rm -rf alpine-minirootfs-$version-x86_64.tar.gz
            if [ ! -f "/etc/schroot/chroot.d/alpine.conf" ] || [ `cat /etc/schroot/chroot.d/alpine.conf|wc -l` -lt 8 ];then
                cat << EOF > /etc/schroot/chroot.d/alpine.conf
[alpine]
description=alpine $version
directory=$chrootp
users=root
groups=root
root-users=root
root-groups=root
type=directory
shell=/bin/sh
EOF
            fi
            echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > $chrootp/etc/apk/repositories \
            && echo "http://mirrors.aliyun.com/alpine/latest-stable/community/"  >> $chrootp/etc/apk/repositories
            cat << EOF >> $chrootp/etc/profile
echo "Welcome to alpine $version chroot."
echo "Create by PveTools."
echo "Author: 龙天ivan"
echo "Github: https://github.com/ivanhao/pvetools"
EOF
            schroot -c alpine apk update
            whiptail --title "Success" --msgbox "Done.
安装配置完成！" 10 60
            docker
            dockerWeb
            configChroot
        else
            configChroot
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
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Enter chroot:" 25 60 15 \
            $(echo $c) \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "进入chroot环境:" 25 60 15 \
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
        else
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
                cat << EOF >> $chrootp/etc/profile
export DOCKER_RAMDISK=true
echo "Docker installed."
for i in {1..10}
do
if [ \`ps aux|grep dockerd|wc -l\` -gt 1 ];then
    break
else
    nohup /usr/bin/dockerd > /dev/null 2>&1 &
fi
done
EOF
                if [ ! -d "$chrootp/etc/docker" ];then
                    mkdir $chrootp/etc/docker
                fi
                if [ $L = "en" ];then
                    cat << EOF > $chrootp/etc/docker/daemon.json
{
    "registry-mirrors": [
        "https://dockerhub.azk8s.cn",
        "https://reg-mirror.qiniu.com",
        "https://registry.docker-cn.com"
    ]
}
EOF
                fi
            else
                configChroot
            fi
        fi
        if [ -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            screen -S docker -X quit
        fi
        if(whiptail --title "Yes/No" --yesno "Install portainer web interface?
是否安装web界面（portainer）？" 10 60);then
            dockerWeb
        else
            clear
        fi
        screen -dmS docker schroot -c alpine -d /root
        configChroot
    }
    dockerWeb(){
        checkSchroot
        checkDocker
        checkDockerWeb
        if [ `cat $chrootp/etc/profile|grep portainer|wc -l` = 0 ];then
            cat << EOF >> $chrootp/etc/profile
if [ ! -d "/root/portainer_data" ];then
    mkdir /root/portainer_data
fi
if [ \`docker ps -a|grep portainer|wc -l\` = 0 ];then
    docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
else
    docker start portainer > /dev/null
fi
echo "Portainer installed."
EOF
        fi

        if [ ! -f "/usr/bin/screen" ];then
            apt-get install screen -y
        fi
        chrootReDaemon
        sleep 5
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker pull portainer/portainer
        fi
        if [ `schroot -c alpine -d /root docker ps -a|grep portainer|wc -l` = 0 ];then
            schroot -c alpine -d /root docker run -d -p 9000:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /root/portainer_data:/data portainer/portainer
        fi
        checkDockerWeb
    }
    checkSchroot(){
        if [ `ls /usr/bin|grep schroot|wc -l` = 0 ] || [ `schroot -l|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No schroot found.Install schroot first.
您还没有安装schroot环境，请先安装。" 10 60
            chRoot
        else
            if [ -f "/etc/schroot/chrootp" ];then
                chrootp=`cat /etc/schroot/chrootp`
            else
                if [ -d "/alpine" ];then
                    chrootp="/alpine"
                    echo $chrootp > /etc/schroot/chrootp
                else
                    whiptail --title "Warnning" --msgbox "Chroot path not found!
没有检测到chroot安装目录！" 10 60
                fi
            fi
        fi
    }
    checkDocker(){
        if [ `ls $chrootp/usr/bin|grep docker|wc -l` = 0 ];then
            whiptail --title "Warnning" --msgbox "No docker found.Install docker first.
您还没有安装docker环境，请先安装。" 10 60
            chRoot
        fi
    }
    checkDockerWeb(){
        if [ `schroot -c alpine -d /root docker images|grep portainer|wc -l` != 0 ];then
            whiptail --title "Warnning" --msgbox "DockerWeb found.Quit.
您已经安装dockerWeb环境。
请进入http://ip:9000使用。
" 10 60
            chRoot
        fi
    }
    chrootReDaemon(){
        if [ `screen -ls|grep docker|wc -l` != 0 ];then
            for i in `screen -ls|grep docker|awk -F " " '{print $1}'|awk -F "." '{print $1}'`
            do
                screen -S $i -X quit
            done
        fi
        screen -dmS docker schroot -c alpine -d /root
        if [ `cat /etc/crontab|grep schroot|wc -l` = 0 ];then
            cat << EOF >> /etc/crontab
@reboot  root  screen -dmS docker schroot -c alpine -d /root
EOF
        fi
        whiptail --title "Success" --msgbox "Chroot daemon done." 10 60
    }
    checkChrootDaemon(){
        if [ `screen -ls|grep docker|wc -l` = 0 ];then
            screen -dmS docker schroot -c alpine -d /root
            if [ `screen -ls|grep docker|wc -l` != 0 ];then
                whiptail --title "Warnning" --msgbox "Chroot daemon started.
已经为您开启chroot后台运行环境。
                " 10 60
                chRoot
            else
                checkChrootDaemon
            fi
        else
            if(whiptail --title "Warnning" --yesno "Chroot daemon already runngin.Restart?
chroot后台运行环境已经运行，需要重启吗？
                " --defaultno 10 60)then
                chrootReDaemon
                checkChrootDaemon
            else
                chRoot
            fi
        fi
        chRoot
    }
    configChroot(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config chroot & docker etc:" 25 60 15 \
            "a" "Config base schroot." \
            "b" "Docker in alpine" \
            "c" "Portainer in alpine" \
            "d" "Change chroot path" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置chroot环境和docker等:" 25 60 15 \
            "a" "配置基本的chroot环境（schroot 默认为alpine)。" \
            "b" "Docker（alpine）。" \
            "c" "Docker配置界面（portainer in alpine）。" \
            "d" "迁移chroot目录到其他路径。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                setChroot
                ;;
            b )
                docker
                #whiptail --title "Warnning" --msgbox "Not supported." 10 60
                chroot
                ;;
            c )
                dockerWeb
                chRoot
                ;;
            d )
                mvChrootp
            esac
        else
            chRoot
        fi
    }
    mvChrootp(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否继续?" --defaultno 10 60)then
            checkSchroot
            chrootpNew=$(whiptail --title "Choose a path" --inputbox "
Current Path:
当前路径：
$(echo $chrootp)
---------------------------------
Input new chroot path:
请输入迁移的新路径：" 20 60 \
"" \
        3>&1 1>&2 2>&3)
            exitstatus=$?
            if [ $exitstatus = 0 ]; then
                while [ true ]
                do
                    if [ ! -d $chrootpNew ];then
                        whiptail --title "Warnning" --msgbox "Path not found.
没有检测到路径，请重新输入" 10 60
                        mvChrootp
                    else
                        break
                    fi
                done
                chrootpNew=${chrootpNew%/}"/alpine"
                echo $chrootpNew > /etc/schroot/chrootp
                for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
                if [ -d "$chrootp/sys/fs/cgroup" ];then
                    mount --make-rslave $chrootp/sys/fs/cgroup
                    umount -R $chrootp/sys/fs/cgroup
                fi
                killall portainer
                killall dockerd
                rsync -a -r -v $chrootp"/" $chrootpNew
                sync
                sync
                sleep 3
                rm -rf $chrootp
                sed -i 's#'$chrootp'#'$chrootpNew'#g' /etc/schroot/chroot.d/alpine.conf
                whiptail --title "Success" --msgbox "Done.
    迁移成功" 10 60
                checkChrootDaemon
            else
                configChroot
            fi
        else
            chRoot
        fi
    }
    delChroot(){
        if (whiptail --title "Yes/No" --yesno "Continue?
是否继续?" --defaultno 10 60)then
            checkSchroot
            for i in `schroot --list --all-sessions|awk -F ":" '{print $2}'`;do schroot -e -c $i;done
            apt-get -y autoremove schroot debootstrap
            if [ -d "$chrootp/sys/fs/cgroup" ];then
                mount --make-rslave $chrootp/sys/fs/cgroup
                umount -R $chrootp/sys/fs/cgroup
            fi
            killall portainer
            killall dockerd
            rm -rf $chrootp
            whiptail --title "Success" --msgbox "Done.
    删除成功" 10 60
        else
            chRoot
        fi
    }
    #--base-funcs-end--
if [ $L = "en" ];then
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config chroot & docker etc:" 25 60 15 \
    "a" "Install & config base schroot." \
    "b" "Enter chroot." \
    "c" "Chroot daemon manager" \
    "d" "Remove all chroot." \
    3>&1 1>&2 2>&3)
else
    x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置chroot环境和docker等:" 25 60 15 \
    "a" "安装配置基本的chroot环境（schroot 默认为alpine)。" \
    "b" "进入chroot。" \
    "c" "Chroot后台管理。" \
    "d" "彻底删除chroot。" \
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
        checkChrootDaemon
        ;;
    d )
        delChroot
esac
else
    main
fi

}

#--qm set <ide,scsi,sata> disk
chQmdisk(){
    clear
    confDisk(){
        list=`qm list|awk 'NR>1{print $1":"$2".................."$3" "}'`
        echo -n "">lsvm
        ls=`for i in $list;do echo $i|awk -F ":" '{print $1" "$2}'>>lsvm;done`
        ls=`cat lsvm`
        rm lsvm
        h=`echo $ls|wc -l`
        let h=$h*1
        if [ $h -lt 30 ];then
            h=30
        fi
        list1=`echo $list|awk 'NR>1{print $1}'`
        vmid=$(whiptail  --title " PveTools   Version : 2.3.3 " --menu "
Choose vmid to set disk:
选择需要配置硬盘的vm：" 20 60 10 \
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
                        chQmdisk
                    else
                        break
                    fi
                done
                if [ $1 = 'add' ];then
                    #disks=`ls -alh /dev/disk/by-id|awk '{print $11" "$9" OFF"}'|awk -F "/" '{print $3}'|sed '/^$/d'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'`
                    #added=`cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3"\r\n"}'`
                    disks=`ls -alh /dev/disk/by-id|sed '/\.$/d'|sed '/^$/d'|awk 'NR>1{print $9" "$11" OFF"}'|sed 's/\.\.\///g'|sed '/wwn/d'|sed '/^dm/d'|sed '/lvm/d'|sed '/nvme-nvme/d'`
                    d=$(whiptail --title " PveTools Version : 2.3.3 " --checklist "
disk list:
已添加的硬盘:
$(cat /etc/pve/qemu-server/$vmid.conf|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2" "$3}')
-----------------------
Choose disk:
选择硬盘：" 30 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    t=$(whiptail --title " PveTools Version : 2.3.3 " --menu "
Choose disk type:
选择硬盘接口类型：" 20 60 10 \
                    "sata" "vm sata type" \
                    "scsi" "vm scsi type" \
                    "ide" "vm ide type" \
                    3>&1 1>&2 2>&3)
                    exits=$?
                    if [ $exitstatus = 0 ] && [ $exits = 0 ]; then
                        did=`qm config $vmid|sed -n '/^'$t'/p'|awk -F ':' '{print $1}'|sort -u -r|grep '[0-9]*$' -o|awk 'NR==1{print $0}'`
                        if [ $did ];then
                            did=$((did+1))
                        else
                            did=0
                        fi
                        #d=`ls -alh /dev/disk/by-id|grep $d|awk 'NR==1{print $9}'`
                        d=`echo $d|sed 's/\"//g'`
                        for i in $d
                        do
                            if [ `cat /etc/pve/qemu-server/$vmid.conf|grep $i|wc -l` = 0 ];then
                                #if [ $t = "ide" ] && [ `echo $i|grep "nvme"|wc -l` -gt 0 ];then
                                if [ $t = "ide" ] && [ $did -gt 3 ];then
                                    whiptail --title "Warnning" --msgbox "ide is greate then 3.
ide的类型已经超过3个,请重选其他类型!" 10 60
                                else
                                    qm set $vmid --$t$did /dev/disk/by-id/$i
                                fi
                                sleep 1
                                did=$((did+1))
                            fi
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
                if [ $1 = 'rm' ];then
                    disks=`qm config $vmid|grep -E '^ide[0-9]|^scsi[0-9]|^sata[0-9]'|awk -F ":" '{print $1" "$2$3" OFF"}'`
                    d=$(whiptail --title " PveTools Version : 2.3.3 " --checklist "
Choose disk:
选择硬盘：" 20 90 10 \
                    $(echo $disks) \
                    3>&1 1>&2 2>&3)
                    exitstatus=$?
                    if [ $exitstatus = 0 ]; then
                        for i in $d
                        do
                            i=`echo $i|sed 's/\"//g'`
                            qm set $vmid --delete $i
                        done
                        whiptail --title "Success" --msgbox "Done.
配置完成" 10 60
                        chQmdisk
                    else
                        chQmdisk
                    fi
                fi
            else
                chQmdisk
            fi
        fi

    }
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Config qm set disks:" 25 60 15 \
        "a" "set disk to vm." \
        "b" "unset disk to vm." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "配置qm set 物理硬盘给虚拟机:" 25 60 15 \
        "a" "添加硬盘给虚拟机。" \
        "b" "删除虚拟机里的硬盘。" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            clear
            confDisk add
            ;;
        b )
            clear
            confDisk rm
        esac
    fi
}


manyTools(){
    clear
    nMap(){
        clear
        if [ ! -f "/usr/bin/nmap" ];then
            apt-get install nmap -y
        fi
        map=$(whiptail --title "nmap tools." --inputbox "
Input the Ip address.(192.168.1.0/24)
输入局域网ip地址段。（例子：192.168.1.0/24)
        " 10 60 \
        "" \
        3>&1 1>&2 2>&3)
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            while [ true ]
            do
                if [ ! `echo $map|grep "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\/[0-9]*$"` ];then
                    whiptail --title "Warnning" --msgbox "
Wrong format!!!   input again:
格式不对！！！请重新输入：
                    " 10 60
                    nMap
                else
                    break
                fi
            done
            maps=`nmap -sP $map`
            whiptail --title "nmap tools." --msgbox "
$maps
            " --scrolltext 30 60
        else
            manyTools
        fi
    }
    setDns(){
        clear
        dname=`cat /etc/resolv.conf|grep 'nameserver'`
        if [ `cat /etc/resolv.conf|grep 'nameserver'|wc -l` != 0 ];then
            if [ $L = "en" ];then
                d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "DNS - Many Tools:
Detect exist nameserver,Please choose:
                " 25 60 15 \
                "a" "Add nameserver." \
                "b" "Replace nameserver." \
                3>&1 1>&2 2>&3)
            else
                d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "DNS - 常用的工具:
检测到已经配置有dns服务器: \
$(for i in $dname;do echo $i ;done)  \
------------------------------ \
请选择以下操作：
                " 25 60 15 \
                "a" "添加dns." \
                "b" "替换dns." \
                3>&1 1>&2 2>&3)
            fi
            exitstatus=$?
            if [ $exitstatus != 0 ]; then
                manyTools
            fi
        fi
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "DNS - Many Tools:" 25 60 15 \
            "a" "8.8.8.8(google)." \
            "b" "223.5.5.5(alidns)." \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "DNS - 常用的工具:" 25 60 15 \
            "a" "8.8.8.8(谷歌)." \
            "b" "223.5.5.5(阿里)." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                dn="8.8.8.8"
                case "$d" in
                    b )
                        echo "nameserver    8.8.8.8" > /etc/resolv.conf
                esac
                echo "nameserver    8.8.8.8" >> /etc/resolv.conf
                ;;
            b )
                dn="223.5.5.5"
                case "$d" in
                    b )
                        echo "nameserver    223.5.5.5" > /etc/resolv.conf
                esac
                echo "nameserver    223.5.5.5" >> /etc/resolv.conf
                ;;
            esac
            if [ `cat /etc/resolv.conf | grep ${dn}|wc -l` != 0 ];then
                whiptail --title "Success" --msgbox "Done.
配置完成。"  10 60
                manyTools
            else
                whiptail --title "Warnning" --msgbox "Unsuccess.Please retry.
配置未成功。请重试。"  10 60
                setDns
            fi
        else
            manyTools
        fi
    }
    freeMemory(){
        clear
        if(whiptail --title "Free memory" --yesno "Free memory?
释放内存？" 10 60 );then
            sync
            sync
            sync
            echo 3 > /proc/sys/vm/drop_caches
            echo 0 > /proc/sys/vm/drop_caches
            whiptail --title "Success" --msgbox "Done." 10 60
        else
            manyTools
        fi
    }
    speedTest(){
        op=`pwd`
        cd ~
        git clone https://github.com/sivel/speedtest-cli.git
        chmod +x ~/speedtest-cli/speedtest.py
        python ~/speedtest-cli/speedtest.py
        echo "Enter to continue."
        cd $op
        read x
    }
    bbr(){
        op=`pwd`
        if [ ! -d "/opt/bbr" ];then
            mkdir /opt/bbr
        fi
        cp ./plugins/tcp.sh /opt/bbr
        cd /opt/bbr
        ./tcp.sh
        cd $op
    }
    v2ray(){
        op=`pwd`
        cd ~
        git clone https://github.com/ivanhao/ivan-v2ray
        chmod +x ~/ivan-v2ray/install.sh
        ~/ivan-v2ray/install.sh
        echo "Enter to continue."
        cd $op
        read x
    }
    darkMode(){
        if [ $L = "en" ];then
            d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "DarkMode - Many Tools:
            " 25 60 15 \
            "a" "Install." \
            "b" "Uninstall." \
            3>&1 1>&2 2>&3)
        else
#----------------- 请选择以下操作：----------------- \
            d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "界面黑暗模式 - 常用的工具:
            " 25 60 15 \
            "a" "安装." \
            "b" "卸载." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$d" in
            a )
                if(whiptail --title "DarkMode" --yesno "install DarkMode?
        安装黑暗模式界面？" 10 60 );then
                    wget https://gitee.com/ivanhao1984/PVEDiscordDark/raw/master/install.sh -O - | bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            b )
                if(whiptail --title "DarkMode" --yesno "uninstall DarkMode?
        卸载黑暗模式界面？" 10 60 );then
                    wget https://gitee.com/ivanhao1984/PVEDiscordDark/raw/master/uninstall.sh -O - | bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            esac
        fi
        manyTools
    }
    vbios(){
        echo "..."
        if(whiptail --title "vbios tools" --yesno "get vbios?
提取显卡？" 10 60 );then
            cd ..
            git clone https://github.com/ivanhao/envytools
            cd envytools
            apt-get install cmake flex libpciaccess-dev bison libx11-dev libxext-dev libxml2-dev libvdpau-dev python3-dev cython3 pkg-config
            cmake .
            make
            make install
            nvagetbios -s prom > vbios.bin
            cd ..
            git clone https://github.com/awilliam/rom-parser
            cd rom-parser
            make
            ./rom-parser ../envytools/vbios.bin
            sleep 5
            if [ `rom-parser ../envytools/vbios.bin|grep Error|wc -l` = 0 ];then
                cp ../envytools/vbios.bin /usr/share/kvm/
                whiptail --title "Success" --msgbox "Done.see vbios in '/usr/share/kvm/vbios.bin'
提取显卡vbios成功，文件在'/usr/share/kvm/vbios.bin',可以直接在配置文件中添加romfile=vbios.bin" 10 60
            else
                whiptail --title "Warnning" --msgbox "Room parse error.
提取显卡vbios失败。" 10 60
            fi

        fi
        manyTools

    }
    folder2ram(){
        if [ $L = "en" ];then
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "folder2ram:" 25 60 15 \
            "a" "install" \
            "b" "Uninstall" \
            3>&1 1>&2 2>&3)
        else
            x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "USB设备做为系统盘的优化:" 25 60 15 \
            "a" "安装。" \
            "b" "卸载。" \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$x" in
            a )
                if(whiptail --title "vbios tools" --yesno "install folder2ram to optimaz USB OS storage?
        安装USB设备做为系统盘的优化？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/install.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            b )
                if(whiptail --title "vbios tools" --yesno "uninstall folder2ram optimaz?
        卸载USB设备做系统盘的优化？" 10 60 );then
                    wget https://raw.githubusercontent.com/ivanhao/pve-folder2ram/master/uninstall.sh -O -| bash
                    whiptail --title "Success" --msgbox "Done. \
配置完成" 10 60
                fi
                ;;
            esac
        fi
        manyTools
    }

    autoResize(){
        if [ $L = "en" ];then
            d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "autoResize ROOT partition - Many Tools:
            " 25 60 15 \
            "a" "start." \
            3>&1 1>&2 2>&3)
        else
#----------------- 请选择以下操作：----------------- \
            d=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "自动扩展ROOT分区可用空间 - 常用的工具:
            " 25 60 15 \
            "a" "运行." \
            3>&1 1>&2 2>&3)
        fi
        exitstatus=$?
        if [ $exitstatus = 0 ]; then
            case "$d" in
            a )
                if(whiptail --title "autoResize" --yesno "run autoResize on /(only LVM partition)?
                    是否运行自动扩展ROOT分区(LVM)可用空间？
                    注意：zfs等非LVM分区不可使用，即便运行也不产生影响。" 15 60 );then
                    ./plugins/autoResize ivanhao/pvetools > ./autoResize.log 2>&1
                    #autoResizeLog=`cat ./autoResize.log`
                    echo "Done." > ./autoResize.log
                    echo "配置完成。" > ./autoResize.log
                    whiptail --title "Success" --scrolltext --textbox "./autoResize.log" 30 60
                    rm ./autoResize.log
                fi
                ;;
            esac
        fi
        manyTools
    }

    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Many Tools:" 25 60 15 \
        "a" "Local network scans(nmap)." \
        "b" "Set DNS." \
        "c" "Free Memory." \
        "d" "net speedtest" \
        "e" "bbr\\bbr+" \
        "f" "config v2ray" \
        "g" "Nvida Video Card vbios" \
        "h" "folder2ram" \
        "i" "DarkMode" \
        "j" "autoResize ROOT partition" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "常用的工具:" 25 60 15 \
        "a" "局域网扫描。" \
        "b" "配置DNS。" \
        "c" "释放内存。" \
        "d" "speedtest测速" \
        "e" "安装bbr\\bbr+" \
        "f" "配置v2ray" \
        "g" "显(N)卡vbios提取" \
        "h" "USB设备做为系统盘的优化" \
        "i" "黑暗模式界面" \
        "j" "自动扩展ROOT分区可用空间" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            nMap
            ;;
        b )
            setDns
            ;;
        c )
            freeMemory
            ;;
        d )
            speedTest
            ;;
        e )
            bbr
            ;;
        f )
            v2ray
            ;;
        g )
            vbios
            ;;
        h|H )
            folder2ram
            ;;
        i|I )
            darkMode
            ;;
        j|J )
            autoResize
            ;;
        esac
    fi

}
chNFS(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "NFS:" 25 60 15 \
        "a" "Install nfs server." \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "NFS:" 25 60 15 \
        "a" "安装NFS服务器。" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            if(whiptail --title "Yes/No" --yesno "Comfirm?
是否安装？" 10 60)then
                apt-get install nfs-kernel-server
                whiptail --title "OK" --msgbox "Complete.If you use zfs use 'zfs set sharenfs=on <zpool> to enable NFS.'
安装配置完成。如果你使用zfs，执行'zfs set sharenfs=on <zpool>来开启NFS。" 10 60
            else
                chNFS
            fi
            ;;
        esac
    fi


}
sambaOrNfs(){
    if [ $L = "en" ];then
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    else
        x=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "Samba or NFS:" 25 60 15 \
        "a" "samba." \
        "b" "NFS" \
        3>&1 1>&2 2>&3)
    fi
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case "$x" in
        a )
            chSamba
            ;;
        b )
            chNFS
        esac
    fi


}

omvInPve(){
    if(whiptail --title "Yes/No" --yesno "Install omv in proxmox ve directlly?
将要在proxmox ve中直接安装omv,请确认是否继续：" 10 60);then
        if [ -f "/usr/sbin/omv-engined" ];then
            if(whiptail --title "Yes/No" --yesno "Already installed omv in proxmox ve.Reinstall?
已经检测到安装了omv,请确认是否重装？" 10 60);then
                echo "reinstalling..."
            else
                main
            fi
        fi
        apt-get -y install git
        cd ~
        git clone https://github.com/ivanhao/omvinpve
        cd omvinpve
        ./OmvInPve.sh
        main
    else
        main
    fi
}



ConfBackInstall(){
    path(){
x=$(whiptail --title "config path" --inputbox "Input backup path:
输入备份路径:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! -d $x ];then
        whiptail --title "Warnning" --msgbox "Path not found." 10 60
        path
    fi
else
    main
fi
    }
    count(){
y=$(whiptail --title "config backup number" --inputbox "Input backup last number:
输入保留备份数量:" 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ];then
    if [ ! `echo $y|grep '^[0-9]$'` ];then
        whiptail --title "warnning" --msgbox "Invalid content,retry!" 10 60
        count
    fi
else
    main
fi
    }
    path
    count
    x=$x'/pveConfBackup'
    if [ ! -d $x ];then
        mkdir $x
    fi
    if [ ! -d $x/`date '+%Y%m%d'` ];then
        mkdir $x/`date '+%Y%m%d'`
    fi
    cp -rf /etc/pve/qemu-server/* $x/`date '+%Y%m%d'`/
    d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    while [ $d -gt $y ]
    do
        rm -rf $x'/'`ls -l $x|awk 'NR>1{print $9}'|head -n 1`
        d=`ls -l $x|awk 'NR>1{print $9}'|wc -l`
    done
    cat << EOF > /usr/bin/pveConfBackup
#!/bin/bash
x='$x'
y=$y
if [ ! -d $x/`date '+%Y%m%d'` ];then
    mkdir $x/`date '+%Y%m%d'`
fi
cp -r /etc/pve/qemu-server/* $x/\`date '+%Y%m%d'\`/
d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
while [ \$d -gt \$y ]
do
    rm -rf $x/\`ls -l $x|awk 'NR>1{print \$9}'|head -n 1\`
    d=\`ls -l $x|awk 'NR>1{print \$9}'|wc -l\`
done
EOF
    chmod +x /usr/bin/pveConfBackup
    sed -i '/pveConfBackup/d' /etc/crontab
    echo "0  0  *  *  *  root  /usr/bin/pveConfBackup" >> /etc/crontab
    systemctl restart cron
    whiptail --title "success" --msgbox "Install complete." 10 60
    main
}
ConfBackUninstall(){
    if [ `cat /etc/crontab|grep pveConfBackup|wc -l` -gt 0 ];then
        sed -i '/pveConfBackup/d' /etc/crontab
        rm -rf /usr/bin/pveConfBackup
        whiptail --title "success" --msgbox "Uninstall complete." 10 60
    else
        whiptail --title "warnning" --msgbox "No installration found." 10 60
    fi
    main
}
ConfBack(){
OPTION=$(whiptail --title " pve vm config backup " --menu "
auto backup /etc/pve/qemu-server path's conf files.
自动备份/etc/pve/qemu-server路径下的conf文件
Select: " 25 60 15 \
    "a" "Install. 安装" \
    "b" "Uninstall. 卸载" \
3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    case "$OPTION" in
a | A )
        ConfBackInstall
        ;;
b | B)
        ConfBackUninstall
        ;;
* )
        ConfBack
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
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "
Github: https://github.com/ivanhao/pvetools
Please choose:" 25 60 15 \
    "b" "Config apt source(change to ustc.edu.cn and so on)." \
    "c" "Install & config samba or NFS." \
    "d" "Install mailutils and config root email." \
    "e" "Config zfs_arc_max & Install zfs-zed." \
    "f" "Install & config VIM." \
    "g" "Install cpufrequtils to save power." \
    "h" "Config hard disks to spindown." \
    "i" "Config PCI hardware pass-thrugh." \
    "j" "Config web interface to display sensors data and CPU Freq." \
    "k" "Config enable Nested virtualization." \
    "l" "Remove subscribe notice." \
    "m" "Config chroot & docker etc." \
    "n" "Many tools." \
    "p" "Auto backup vm conf file." \
    "u" "Upgrade this script to new version." \
    "L" "Change Language." \
    3>&1 1>&2 2>&3)
else
    OPTION=$(whiptail --title " PveTools   Version : 2.3.3 " --menu "
Github: https://github.com/ivanhao/pvetools
请选择相应的配置：" 25 60 15 \
    "b" "配置apt国内源(更换为ustc.edu.cn,去除企业源等)" \
    "c" "安装配置samba或NFS" \
    "d" "安装配置root邮件通知" \
    "e" "安装配置zfs最大内存及zed通知" \
    "f" "安装配置VIM" \
    "g" "安装配置CPU省电" \
    "h" "安装配置硬盘休眠" \
    "i" "配置PCI硬件直通" \
    "j" "配置pve的web界面显示传感器温度、CPU频率" \
    "k" "配置开启嵌套虚拟化" \
    "l" "去除订阅提示" \
    "m" "配置chroot环境和docker等" \
    "n" "常用的工具" \
    "p" "自动备份虚拟机conf文件" \
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
            sambaOrNfs
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
        n )
            manyTools
            main
            ;;
        o )
            omvInPve
            ;;
        p )
            ConfBack
            ;;
        u )
            git pull
            echo "Now go to main interface:"
            echo "即将回主界面。。。"
            echo "3"
            sleep 1
            echo "2"
            sleep 1
            echo "1"
            sleep 1
            ./pvetools.sh
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
#--------santa-start--------------
DrawTriangle() {
	a=$1
	color=$[RANDOM%7+31]
	if [ "$a" -lt "8" ] ;then
		b=`printf "%-${a}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$a)/2"|bc`
        d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	elif [ "$a" -ge "8" -a "$a" -le "21" ] ;then
		e=$[a-8]
		b=`printf "%-${e}s\n" "0" |sed 's/\s/0/g'`
		c=`echo "(31-$e)/2"|bc`
		d=`printf "%-${c}s\n"`
		echo "${d}`echo -e "\033[1;5;${color}m$b\033[0m"`"
	fi
}
DrawTree() {
	e=$1
	b=`printf "%-3s\n" "|" | sed 's/\s/|/g'`
	c=`echo "($e-3)/2"|bc`
	d=`printf "%-${c}s\n" " "`
	echo -e "${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}\n${d}${b}"
    echo "       Merry Cristamas!"
}
Display(){
	for i in `seq 1 2 31`; do
		[ "$i"="21" ] && DrawTriangle $i
		if [ "$i" -eq "31" ];then
			DrawTree $i
		fi
	done
}
if [[ `date +%m%d` = 1224  ||  `date +%m%d` = 1225 ]] && [ ! -f '/tmp/santa' ];then
    for i in {1..6}
    do
        Display
        sleep 1
        clear
    done
    touch /tmp/santa
fi

#--------santa-end--------------
if (whiptail --title "Language" --yes-button "中文" --no-button "English"  --yesno "Choose Language:
选择语言：" 10 60) then
    L="zh"
else
    L="en"
fi
main
