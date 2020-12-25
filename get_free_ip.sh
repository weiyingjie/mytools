#/bin/bash

# 获取当前局域网内空闲IP
# 结果将输出排序后的空闲IP
# 目前执行完成用时1m左右


flag=0
ping_ip="10.10.0."
arp_ips=$(arp -a | awk -F'\\(|\\)' '{print $2}')

TMP_PATH=/tmp/ip_temp
echo '' > $TMP_PATH

# 测试指定IP是否被占用
if [ -n "$1" ] 
then
    if [ "$1" == "test" -a -n "$2" ]
    then
        testip=$2
        echo -e "检测 $testip\n"
        ping $testip -c 4 -W 3 &> /dev/null
        if [ $? -ne 0 ]
        then
            for arp_ip in $arp_ips
            do
                if [ $testip == $arp_ip ]
                then
                    flag=1
                else
                    flag=0
                fi
            done
        else
            flag=1
        fi
        if [ $flag == 1 ]
        then
            echo "$testip 被占用"
        else
            echo "$testip 空闲"
        fi
    else
        echo "Usage: $0 [test] [ip]"
        exit 1
    fi
    exit 0
fi

for((i=100; i<250; i++))
do
{
    temp=$ping_ip$i
    ping $temp -c 4 -W 3 &> /dev/null
    if [ $? -ne 0 ]
    then
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

ps aux | grep "-c 4 -W 3" | grep -v "grep" &> /dev/null
if [ $? -ne 0 ]
then
    sort -n -t . -k 4 $TMP_PATH # 排序输出
    rm $TMP_PATH -f
fi



