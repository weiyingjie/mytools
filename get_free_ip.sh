#/bin/bash

# 获取当前局域网内空闲IP
# 结果将输出排序后的空闲IP
# 目前执行完成用时1m左右

flag=0
ping_ip="10.10.0."

TMP_PATH=/tmp/ip_temp
echo '' > $TMP_PATH

for((i=50; i<250; i++))
do
{
    temp=$ping_ip$i
    ping $temp -c 4 -W 3 &> /dev/null
    if [ $? -ne 0 ]
    then
        arp_ips=$(arp -a | awk -F'\\(|\\)' '{print $2}')

        for arp_ip in $arp_ips
        do
            if [ $temp == $arp_ip ]
            then
                flag=1
            fi
        done
        if [ $flag == 0 ]
        then
            echo "$temp" >> $TMP_PATH
        fi
    fi
} &
done

wait # 等待所有进程结束

ps aux | grep arp | grep -v "grep" &> /dev/null
if [ $? -ne 0 ]
then
    sort -n -t . -k 4 $TMP_PATH # 排序输出
    rm $TMP_PATH -f
fi



