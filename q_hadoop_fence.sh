#!/bin/bash
usage(){
    echo "Usage: $0 hostname port"
    echo "Note: hostname can not be ip"
    exit 1
}

# invoke  usage
# call usage() function if filename not supplied
[[ $# -ne 2 ]] && usage

LOG_FILE=/tmp/hadoop_fence.log

q_namenode.sh $1 $2 2>&1 | tee -a $LOG_FILE
