#!/bin/bash

# 修改网卡名称
function change_ifname() 
{
	local if_MAC=`ip a | grep " ens" -A 1 | awk '/link/{print $2}'`
	local if_name=`ip a | awk -F':| ' '/ en[sop]/{print $3}'`
	local if_count=0
	local if_path="/etc/udev/rules.d/70-persistent-net.rules"
	local if_num=6
	local ixgbe_cur_num=2
	local ixgbe_count=0

	if [ -f "$if_path" ]
	then
		rm $if_path
	fi

	# 查看万兆口数量，保证都识别到
	for name in $if_name
	do
		(ethtool $name | grep 10000base) > /dev/null
		if [ $? -eq 0 ]
		then
			let ixgbe_count=$ixgbe_count+1
		fi
	done

	# 万兆口没起来，重装驱动
	if [ $ixgbe_count -ne $ixgbe_cur_num ]
	then
		rmmod ixgbe
		modprobe ixgbe allow_unsupported_sfp=1
	fi

	if_MAC=`ip a | grep " en[op]" -A 1 | awk '/link/{print $2}'`
	for mac in $if_MAC
	do
		echo "SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$mac\", NAME=\"eth$if_count\"" >> $if_path
		let if_count=$if_count+1
	done

	for((i = $if_num; i >= 0; i--))
	do
		(ip a | grep " ens$i") > /dev/null
		if [ $? -eq 0 ]
		then
			if_MAC=`ip a | grep " ens$i" -A 1 | awk '/link/{print $2}'`
			for mac in $if_MAC
			do
				echo "SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$mac\", NAME=\"eth$if_count\"" >> $if_path
				let if_count=$if_count+1
			done
		fi

	done
}

change_ifname
