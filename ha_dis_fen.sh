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
username="hadoop"
CONN_TIMEOUT=5

# check hostname
if valid_ip $1; then
    usage
fi

unreached_hosts=0
for element in "${zkhosts[@]}"; do
    echo "try to connect $element to execute fence!"
    ssh -o ConnectTimeout=$CONN_TIMEOUT $username@$element "hadoop_fence.sh $host $port" &
done

# wait the jobs
for job in `jobs -p`
do
    echo "wait job $job"
    wait $job
    if [ $? -eq 0 ]; then
        let "unreached_hosts+=1"
    elif [ $? -eq 2 ]; then
        echo "Host can not ssh when kill!"
    elif [ $? -eq 1 ]; then
        exit 0
    elif [ $? -eq 3 ]; then
        exit 1
    fi
done

zknum=${#zkhosts[@]}
let qurom=zknum/2
echo "$unreached_hosts zks kill the active namenode successfully!"
if [ $unreached_hosts -gt $qurom ];then
    echo "Fence successfully!"
    exit 0
else
    echo "Not enough zks kill the active namenode!"
    exit 1
fi
