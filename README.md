# pvetools
pve tools script.Including install samba and config set zfs max ram etc.
``
echo "deb https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free                                                                              |~                                       
deb-src https://mirrors.ustc.edu.cn/debian/ $sver main contrib non-free                                                                                        |~                                       
deb https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free                                                                                    |~                                       
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-updates main contrib non-free                                                                                |~                                       
deb https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free                                                                                  |~                                       
deb-src https://mirrors.ustc.edu.cn/debian/ $sver-backports main contrib non-free                                                                              |~                                       
deb https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free                                                                           |~                                       
deb-src https://mirrors.ustc.edu.cn/debian-security/ $sver/updates main contrib non-free" > /etc/apt/sources.list  
apt update
apt -y install git 
git clone https://github.com/ivanhao/pvetools
```
