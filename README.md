##Qunar hadoop fence
============

When we use the hadoop native auto-failover, we have to set the dfs.ha.fencing.methods,
and the default method is sshfence, but there is one situation auto-failover can not be
execute successfully.

When the active namenode server is shutdown, the auto-failover will stop at the sshfence,
cause the sshfence try to ssh the active namenode and kill the process. But the server is
down.

So I write the script which proivde a new method for fence.

### File Structure

q_hadoop_fence.sh: The script is used by the hadoop configureation : dfs.ha.fencing.methods,
                   and the file should be deployed at the two namenodes at system path.
q_namenode.sh: The script is invoked by q_hadoop_fence.sh which implement the true fence function.
q_datanode.sh: The script is used for datanode to check the dead node is truly dead.

### How to deploy the scripts

1. Modify the hadoop option dfs.ha.fencing.methods as below:
   <property>
    <name>dfs.ha.fencing.methods</name>
    <value>
        sshfence
        q_hadoop_fence.sh $target_host $target_port
    </value>
   </propery>

2. Modify some variables according to your cluster
   * q_hadoop_fence.sh
     1. LOG_FILE, identify which file will log the message of fence
   * q_namenode.sh
     1. zkhosts, identify the hostnames where q_datanode.sh deployed.
     2. username, identify which user will be used as ssh user
   * q_datanode.sh
     1.CONN_TIMEOUT, identify the ssh connection timeout value.
