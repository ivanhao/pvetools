if [ -f "/etc/schroot/default/fstab" ];then
    echo << EOF >> /etc/schroot/default/fstab
/run/udev       /run/udev       none    rw,bind         0       0 
/sys/fs/cgroup  /sys/fs/cgroup  none    rw,rbind        0       0 
EOF
    sed -i '/\/home/d' /etc/schroot/default/fstab
fi
if [ ! -f "/etc/schroot/chroot.d/alpine.conf" ] || [ `cat /etc/schroot/chroot.d/alpine.conf|wc -l` -lt 8 ];then
    echo << EOF > /etc/schroot/chroot.d/alpine.conf
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
 
