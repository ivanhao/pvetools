#!/bin/bash
# Author:SongQiang
# Create Time:Sun 28 Apr 2019 09:31:19 PM CST
# File Name:function.sh
# Description
 
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
    echo "   Press  'enter' to stop"
    echo "        按'回车'退出"
}
Display(){
	for i in `seq 1 2 31`; do
		[ "$i"="21" ] && DrawTriangle $i
		if [ "$i" -eq "31" ];then	
			DrawTree $i
		fi
	done
}
while :
do
	Display
	sleep 3
    clear
    #read x
    #case $x in
    #    '' )
    #        break
    #esac
done

exit
