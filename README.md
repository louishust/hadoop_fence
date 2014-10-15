##hadoop_fence
============

When we use the hadoop native auto-failover, we have to set the dfs.ha.fencing.methods,
and the default method is sshfence, but there is one situation auto-failover can not be
execute successfully.

When the active namenode server is shutdown, the auto-failover will stop at the sshfence,
cause the sshfence try to ssh the active namenode and kill the process. But the server is
down.

So I write the script which proivde a new method for fence.

### How to deploy the scripts

1. deploy the ha_dis_fen.sh at the namenodes
2. deploy the hadoop_fence.sh at the zookeeper cluster
3. Modify the ha_dis_fen.sh file and set the zkhosts and username variables
4. Modify the hadoop_fence.sh file, set the username variables
