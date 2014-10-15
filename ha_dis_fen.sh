#!/bin/bash
usage(){
    echo "Usage: $0 hostname port"
    echo "Note: hostname can not be ip"
    exit 1
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# invoke  usage
# call usage() function if filename not supplied
[[ $# -ne 2 ]] && usage

host=$1
port=$2
zkhosts=("ubuntu" "ubuntu" "ubuntu")
username="louis"

# check hostname
if valid_ip $1; then
    usage
fi

suc_num=0
for element in "${zkhosts[@]}"; do
    ping -c 1 $element > /dev/null
    if [ $? -eq 1 ]; then
        echo "Host $element can not be reached!"
    else
        echo "$element try to execute fence!"
        ssh $username@$element "hadoop_fence.sh $host $port"
        if [ $? -eq 0 ]; then
            let "suc_num+=1"
        fi
    fi
done

zknum=${#zkhosts[@]}
let qurom=zknum/2
echo "$suc_num zks kill the active namenode successfully!"
if [ $suc_num -gt $qurom ];then
    echo "Fence successfully!"
    exit 0
else
    echo "Not enough zks kill the active namenode!"
    exit 1
fi
