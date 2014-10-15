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
username="louis"

# check hostname
if valid_ip $1; then
    usage
fi

# 1. ping the host
ping -c 1 $host > /dev/null
if [ $? -eq 1 ]; then
    echo "Host can not be reached!"
    exit 0
fi

# 2. try to kill the process
ssh $username@$host "fuser -v -k -n tcp $port"

if [ $? -eq 0 ]; then
    echo "Kill the active namenode successfully!"
    exit 0
else
# 3. check the port works
    ssh $username@$host "nc -z $host $port"
    if [ $? -eq 0 ]; then
        echo "Unable to fence - it is running but we cannot kill it!"
        exit 1
    else
        echo "Active namenode process have been killed!"
        exit 0
    fi
fi
