# Title: Mesos scripts
# Maintainer: Yongbok Kim (ruo91@yongbok.net)
#!/bin/bash

# ZooKeeper
ZK_PORT="2181"
ZK_QUORUM_NUM="1"
ZK_ZNODE_PATH="mesos"
ZK_LEADER_PORT="3888"
ZK_FOLLOW_PORT="2888"
ZK_SERVER_1="172.17.1.4"
ZK_SERVER_2="172.17.1.5"
ZK_SERVER_3="172.17.1.6"
ZK_CONFIG="/etc/zookeeper/conf/zoo.cfg"
ZK_CONFIG_MYID="/etc/zookeeper/conf/myid"

# Mesos Master
CLUSTER_NAME="mesos-cluster"
MESOS_WORK_DIR="/var/lib/mesos"

# Mesos Slave
CONTAINERIZERS="docker"

# Logs
MESOS_SLAVE_LOGS="/tmp/mesos-slave.log"
MESOS_MASTER_LOGS="/tmp/mesos-master.log"

# IP
EXTERNAL_IP="$(ip a s | grep 'eth0' | grep 'inet' | cut -d '/' -f 1 | awk '{ print $2 }')"
PIPEWORK_IP="$(ip a s | grep 'eth1' | grep 'inet' | cut -d '/' -f 1 | awk '{ print $2 }')"

# PID
ZK_PID="$(ps -e | grep 'java' | awk '{ printf $1 "\n" }')"
MESOS_SLAVE_PID="$(ps -e | grep 'mesos-slave' | awk '{ printf $1 "\n" }')"
MESOS_MASTER_PID="$(ps -e | grep 'mesos-master' | awk '{ printf $1 "\n" }')"

# Functions
function f_zk {
  if [ "$PIPEWORK_IP" == "$ZK_SERVER_1" ]; then
      if [ -f "$ZK_CONFIG" ]; then
          # ZooKeeper Quorum
          sed -i '/^\#server\.1/ s:.*:server\.1\='"$ZK_SERVER_1"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.2/ s:.*:server\.2\='"$ZK_SERVER_2"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.3/ s:.*:server\.3\='"$ZK_SERVER_3"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG

          # MyID
          echo '1' > $ZK_CONFIG_MYID

         # Start ZooKeeper
         echo "Start ZooKeeper..."  && sleep 1
         service zookeeper start
         echo "done"

      else
          echo "Not found $ZK_CONFIG files."
      fi

  elif [ "$PIPEWORK_IP" == "$ZK_SERVER_2" ]; then
      if [ -f "$ZK_CONFIG" ]; then
          # ZooKeeper Quorum
          sed -i '/^\#server\.1/ s:.*:server\.1\='"$ZK_SERVER_1"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.2/ s:.*:server\.2\='"$ZK_SERVER_2"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.3/ s:.*:server\.3\='"$ZK_SERVER_3"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG

          # MyID
          echo '2' > $ZK_CONFIG_MYID

         # Start ZooKeeper
         echo "Start ZooKeeper..."  && sleep 1
         service zookeeper start
         echo "done"

      else
          echo "Not found $ZK_CONFIG files."
      fi

  elif [ "$PIPEWORK_IP" == "$ZK_SERVER_3" ]; then
      if [ -f "$ZK_CONFIG" ]; then
          # ZooKeeper Quorum
          sed -i '/^\#server\.1/ s:.*:server\.1\='"$ZK_SERVER_1"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.2/ s:.*:server\.2\='"$ZK_SERVER_2"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG
          sed -i '/^\#server\.3/ s:.*:server\.3\='"$ZK_SERVER_3"'\:'"$ZK_FOLLOW_PORT"'\:'"$ZK_LEADER_PORT"':' $ZK_CONFIG

          # MyID
          echo '3' > $ZK_CONFIG_MYID

         # Start ZooKeeper
         echo "Start ZooKeeper..."  && sleep 1
         service zookeeper start
         echo "done"

      else
          echo "Not found $ZK_CONFIG files."
      fi

  else
      echo "IP address does not matching."
  fi
}

function f_zk_manual {
  echo -ne "\033[33m- Number of ZooKeeper Quorum \033[0m \n"
  echo -ne "\033[33m- ex) 3 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_SERVER_NUMBER
  echo

  echo -ne "\033[33m- Number of ZooKeeper MyID \033[0m \n"
  echo -ne "\033[33m- ex) 1 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_MYID
  echo
  echo "$ZK_MYID" > $ZK_CONFIG_MYID

  # Number of ZooKeeper Quorum
  for ((i = 1; i < $ZK_SERVER_NUMBER+1; i++)); do
      echo -ne "\033[33m- ZooKeeper Server $i \033[0m \n"
      echo -ne "\033[33m- ex) 172.17.1.4 \033[0m \n"
      echo -ne "\033[33m- Input: \033[0m"
      read ZK_SERVER
      echo

      if [ -f "$ZK_CONFIG" ]; then
          # ZooKeeper Quorum
          echo "server.$i=$ZK_SERVER:$ZK_FOLLOW_PORT:$ZK_LEADER_PORT" >> $ZK_CONFIG

         # Start ZooKeeper
         echo "Start ZooKeeper..."  && sleep 1
         service zookeeper start
         echo "done"

      else
          echo "Not found $ZK_CONFIG files."
      fi
  done
}

function f_mesos_master {
  # Start Mesos Master
  echo "Start Mesos Master..."  && sleep 1
  mesos-master \
  --cluster=$CLUSTER_NAME \
  --quorum=$ZK_QUORUM_NUM \
  --work_dir=$MESOS_WORK_DIR \
  --zk=zk://$ZK_SERVER_1:$ZK_PORT,$ZK_SERVER_2:$ZK_PORT,$ZK_SERVER_3:$ZK_PORT/$ZK_ZNODE_PATH \
  > $MESOS_MASTER_LOGS 2>&1 &
  echo "done"
}

function f_mesos_master_manual {
  echo -ne "\033[33m- Cluster Name \033[0m \n"
  echo -ne "\033[33m- ex) mesos-cluster \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read CLUSTER_NAME
  echo

  echo -ne "\033[33m- ZooKeeper Servers \033[0m \n"
  echo -ne "\033[33m- ex) 172.17.1.4:2181,172.17.1.5:2181,172.17.1.6:2181 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_SERVERS
  echo

  echo -ne "\033[33m- ZooKeeper Znode PATH \033[0m \n"
  echo -ne "\033[33m- ex) mesos \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_ZNODE_PATH
  echo

  echo -ne "\033[33m- Zookeeper Quorum \033[0m \n"
  echo -ne "\033[33m- ex) 2 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_QUORUM_NUM
  echo

  echo -ne "\033[33m- Mesos WorkDIR \033[0m \n"
  echo -ne "\033[33m- ex) /var/lib/mesos \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read MESOS_WORK_DIR
  echo

  # Start Mesos Master
  echo "Start Mesos Master..."  && sleep 1
  mesos-master \
  --cluster=$CLUSTER_NAME \
  --quorum=$ZK_QUORUM_NUM \
  --work_dir=$MESOS_WORK_DIR \
  --zk=zk://$ZK_SERVERS/$ZK_ZNODE_PATH \
  > $MESOS_MASTER_LOGS 2>&1 &
  echo "done"
}

function f_mesos_slave {
  # Start Mesos Slave
  echo "Start Mesos Slave..."  && sleep 1
  mesos-slave \
  --containerizers=$CONTAINERIZERS \
  --master=zk://$ZK_SERVER_1:$ZK_PORT,$ZK_SERVER_2:$ZK_PORT,$ZK_SERVER_3:$ZK_PORT/$ZK_ZNODE_PATH \
  > $MESOS_SLAVE_LOGS 2>&1 &
  echo "done"
}

function f_mesos_slave_manual {
  echo -ne "\033[33m- ZooKeeper Servers \033[0m \n"
  echo -ne "\033[33m- ex) 172.17.1.4:2181,172.17.1.5:2181,172.17.1.6:2181 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_SERVERS
  echo

  echo -ne "\033[33m- ZooKeeper Znode PATH \033[0m \n"
  echo -ne "\033[33m- ex) mesos \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read ZK_ZNODE_PATH
  echo

  # Start Mesos Slave
  echo "Start Mesos Slave..."  && sleep 1
  mesos-slave \
  --containerizers=$CONTAINERIZERS \
  --master=zk://$ZK_SERVERS/$ZK_ZNODE_PATH \
  > $MESOS_SLAVE_LOGS 2>&1 &
  echo "done"
}

function f_kill_of_process {
  if [[ "$ARG_2" == "mm" || "$ARG_2" == "mesos-master" ]]; then
      echo "Kill of Mesos Master..." && sleep 1
      kill -9 $MESOS_MASTER_PID
      echo "done"

  elif [[ "$ARG_2" == "ms" || "$ARG_2" == "mesos-slave" ]]; then
      echo "Kill of Mesos Slave..." && sleep 1
      kill -9 $MESOS_SLAVE_PID
      echo "done"

  elif [[ "$ARG_2" == "zk" || "$ARG_2" == "zookeeper" ]]; then
      echo "Kill of ZooKeeper..." && sleep 1
      kill -9 $ZK_PID
      echo "done"

  else
      echo "Not found PIDs"
  fi
}

function f_help {
  echo "Usage: $ARG_0 [Options] [Arguments]"
  echo
  echo "- Options"
  echo "zk, zookeeper      : Start ZooKeeper"
  echo "mm, mesos-master   : Start Mesos Master"
  echo "ms, mesos-slave    : Start Mesos Slave"
  echo "k, kill            : kill of process"
  echo
  echo "- Arguments"
  echo "s, start           : Start commands"
  echo "m, manual          : Manual commands"
  echo
  echo "zk, zookeeper      : kill of zookeeper (k or kill option only.)"
  echo "                     ex) $ARG_0 k zk or $ARG_0 kill zookeeper"
  echo
  echo "mm, mesos-master   : kill of mesos-master (k or kill option only.)"
  echo "                     ex) $ARG_0 k mm or $ARG_0 kill mesos-master"
  echo
  echo "ms, mesos-slave    : kill of mesos-slave (k or kill option only.)"
  echo "                     ex) $ARG_0 k ms or $ARG_0 kill mesos-slave"
  echo
}

# Main
ARG_0="$0"
ARG_1="$1"
ARG_2="$2"

case ${ARG_1} in
  zk|zookeeper)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_zk

    elif [[ "$ARG_2" == "m" || "$ARG_2" == "manual"  ]]; then
        f_zk_manual

    else
        f_help
    fi
  ;;

  mm|mesos-master)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_mesos_master

    elif [[ "$ARG_2" == "m" || "$ARG_2" == "manual"  ]]; then
        f_mesos_master_manual

    else
        f_help
    fi
  ;;

  ms|mesos-slave)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_mesos_slave

    elif [[ "$ARG_2" == "m" || "$ARG_2" == "manual"  ]]; then
        f_mesos_slave_manual

    else
        f_help
    fi
  ;;

  zk|zookeeper)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_zk

    elif [[ "$ARG_2" == "m" || "$ARG_2" == "manual"  ]]; then
        f_zk_manual

    else
        f_help
    fi
  ;;

  k|kill)
        f_kill_of_process
  ;;

  *)
    f_help
  ;;

esac

