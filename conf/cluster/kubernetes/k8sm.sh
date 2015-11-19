#------------------------------------------------#
# Kubernetes mesos start script
# Maintainer: Yongbok Kim (ruo91@yongbok.net)
#------------------------------------------------#
#!/bin/bash

### Global ###
# Kubernetes Mesos
K8SM_HOME=/opt/kubernetes
PATH=$PATH:$K8SM_HOME/server/bin

# Common
K8SM_PROVIDER="mesos"
K8SM_COMMON_SERVER_ADDR="0.0.0.0"
K8SM_MESOS_CLOUD_CONFIG="/opt/mesos-clould.conf"

# ETCD
K8SM_ETCD_PORT="4001"
K8SM_ETCD_SERVER="http://172.17.1.1:$K8SM_ETCD_PORT,http://172.17.1.2:$K8SM_ETCD_PORT,http://172.17.1.3:$K8SM_ETCD_PORT"

# API Server
K8SM_API_SERVER="172.17.1.7"
K8SM_API_SERVER_PORT="8080"
K8SM_API_SERVER_CLUSTER_IP_RANGE="10.0.0.0/16"

# Scheduler
K8SM_SCHEDULER_MESOS_USER="root"
K8SM_SCHEDULER_MESOS_MASTER="zk://172.17.1.4:2181,172.17.1.5:2181,172.17.1.6:2181/mesos"
K8SM_SCHEDULER_CLUSTER_DNS="10.10.10.10"
K8SM_SCHEDULER_CLUSTER_DOMAIN="cluster.local"

# Controller Manager

# Logs
K8SM_API_SERVER_LOGS="/tmp/apiserver.log"
K8SM_SCHEDULER_LOGS="/tmp/scheduler.log"
K8SM_CONTROLLER_LOGS="/tmp/controller-manager.log"

# PIDs
K8SM_API_SERVER_PID="$(ps -ef | grep -v grep | grep 'km apiserver' | awk '{ printf $2 "\n" }')"
K8SM_SCHEDULER_SERVER_PID="$(ps -ef | grep -v grep | grep 'km scheduler' | awk '{ printf $2 "\n" }')"
K8SM_CONTROLLER_SERVER_PID="$(ps -ef | grep -v grep | grep 'km controller-manager' | awk '{ printf $2 "\n" }')"

# Functions
function f_apiserver {
  echo "Start API Server..."  && sleep 1
  km apiserver \
  --address=$K8SM_COMMON_SERVER_ADDR \
  --etcd-servers=$K8SM_ETCD_SERVER \
  --service-cluster-ip-range=$K8SM_API_SERVER_CLUSTER_IP_RANGE \
  --port=$K8SM_API_SERVER_PORT \
  --cloud-provider=$K8SM_PROVIDER \
  --cloud-config=$K8SM_MESOS_CLOUD_CONFIG \
  --v=1 > $K8SM_API_SERVER_LOGS 2>&1 &
  echo "done"
}

function f_scheduler {
  echo "Start Scheduler..." && sleep 1
  km scheduler \
  --address=$K8SM_COMMON_SERVER_ADDR \
  --mesos-master=$K8SM_SCHEDULER_MESOS_MASTER \
  --etcd-servers=$K8SM_ETCD_SERVER \
  --mesos-user=$K8SM_SCHEDULER_MESOS_USER \
  --api-servers=$K8SM_API_SERVER:$K8SM_API_SERVER_PORT \
  --cluster-dns=$K8SM_SCHEDULER_CLUSTER_DNS \
  --cluster-domain=$K8SM_SCHEDULER_CLUSTER_DOMAIN \
  --v=2 > $K8SM_SCHEDULER_LOGS 2>&1 &
  echo "done"
}

function f_controller_manager {
  echo "Start Controller Manager..." && sleep 1
  km controller-manager \
  --master=$K8SM_API_SERVER:$K8SM_API_SERVER_PORT \
  --cloud-provider=$K8SM_PROVIDER \
  --cloud-config=$K8SM_MESOS_CLOUD_CONFIG  \
  --v=1 > $K8SM_CONTROLLER_LOGS 2>&1 &
  echo "done"
}

# Function of manual
function f_apiserver_manual {
  echo -ne "\033[33m- API Server Port \033[0m \n"
  echo -ne "\033[33m- ex) 8080 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER_PORT
  echo

  echo -ne "\033[33m- API Server Service Address \033[0m \n"
  echo -ne "\033[33m- ex) 0.0.0.0 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_COMMON_SERVER_ADDR
  echo

  echo -ne "\033[33m- Cloud Provider \033[0m \n"
  echo -ne "\033[33m- ex) mesos \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_PROVIDER
  echo

  echo -ne "\033[33m- Cloud Config \033[0m \n"
  echo -ne "\033[33m- ex) /opt/mesos-clould.conf \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_MESOS_CLOUD_CONFIG
  echo

  echo -ne "\033[33m- Service Cluster IP Range (CIDR) \033[0m \n"
  echo -ne "\033[33m- ex) 10.0.42.1/16 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER_CLUSTER_IP_RANGE
  echo

  echo -ne "\033[33m- ETCD Server \033[0m \n"
  echo -ne "\033[33m- ex) http://172.17.1.1:4001,http://172.17.1.2:4001,,http://172.17.1.3:4001\033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_ETCD_SERVER
  echo

  echo "Start API Server..."  && sleep 1
  km apiserver \
  --address=$K8SM_COMMON_SERVER_ADDR \
  --etcd-servers=$K8SM_ETCD_SERVER \
  --service-cluster-ip-range=$K8SM_API_SERVER_CLUSTER_IP_RANGE \
  --port=$K8SM_API_SERVER_PORT \
  --cloud-provider=$K8SM_PROVIDER \
  --cloud-config=$K8SM_MESOS_CLOUD_CONFIG \
  --v=1 > $K8SM_API_SERVER_LOGS 2>&1 &
  echo "done"
}

function f_scheduler_manual {
  echo -ne "\033[33m- Scheduler Service Address \033[0m \n"
  echo -ne "\033[33m- ex) 0.0.0.0 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8S_SCHEDULER_SERVICE_ADDR
  echo

  echo -ne "\033[33m- API Server \033[0m \n"
  echo -ne "\033[33m- ex) 172.17.1.7 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER
  echo

  echo -ne "\033[33m- API Server Port \033[0m \n"
  echo -ne "\033[33m- ex) 8080 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER_PORT
  echo

  echo -ne "\033[33m- Mesos Master Server \033[0m \n"
  echo -ne "\033[33m- ex) 172.17.1.4:5050 or zk://172.17.1.4:2181,172.17.1.5:2181,172.17.1.6:2181/mesos \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_SCHEDULER_MESOS_MASTER
  echo

  echo -ne "\033[33m- Mesos User \033[0m \n"
  echo -ne "\033[33m- ex) root \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_SCHEDULER_MESOS_USER
  echo

#  echo -ne "\033[33m- Cluster DNS \033[0m \n"
#  echo -ne "\033[33m- ex) 10.10.10.10 \033[0m \n"
#  echo -ne "\033[33m- Input: \033[0m"
#  read K8SM_SCHEDULER_CLUSTER_DNS
#  echo

#  echo -ne "\033[33m- Cluster Domain \033[0m \n"
#  echo -ne "\033[33m- ex) cluster.local \033[0m \n"
#  echo -ne "\033[33m- Input: \033[0m"
#  read K8SM_SCHEDULER_CLUSTER_DOMAIN
#  echo

  echo -ne "\033[33m- ETCD Server \033[0m \n"
  echo -ne "\033[33m- ex) http://172.17.1.1:4001,http://172.17.1.2:4001,,http://172.17.1.3:4001\033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_ETCD_SERVER
  echo

  echo "Start Scheduler..." && sleep 1
  km scheduler \
  --address=$K8SM_COMMON_SERVER_ADDR \
  --mesos-master=$K8SM_SCHEDULER_MESOS_MASTER \
  --etcd-servers=$K8SM_ETCD_SERVER \
  --mesos-user=$K8SM_SCHEDULER_MESOS_USER \
  --api-servers=$K8SM_API_SERVER:$K8SM_API_SERVER_PORT \
#  --cluster-dns=$K8SM_SCHEDULER_CLUSTER_DNS \
#  --cluster-domain=$K8SM_SCHEDULER_CLUSTER_DOMAIN \
  --v=2 > $K8SM_SCHEDULER_LOGS 2>&1 &
  echo "done"
}

function f_controller_manager_manual {
  echo -ne "\033[33m- API Server \033[0m \n"
  echo -ne "\033[33m- ex) 172.17.1.7 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER
  echo

  echo -ne "\033[33m- API Server Port \033[0m \n"
  echo -ne "\033[33m- ex) 8080 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_API_SERVER_PORT
  echo

  echo -ne "\033[33m- Controller Manager Service Address \033[0m \n"
  echo -ne "\033[33m- ex) 0.0.0.0 \033[0m \n"
  echo -ne "\033[33m- Input: \033[0m"
  read K8SM_CONTROLLER_SERVICE_ADDR
  echo

  echo "Start Controller Manager..." && sleep 1
  km controller-manager \
  --address=$K8SM_COMMON_SERVER_ADDR \
  --master=$K8SM_API_SERVER:$K8SM_API_SERVER_PORT \
  --cloud-provider=$K8SM_PROVIDER \
  --cloud-config=$K8SM_MESOS_CLOUD_CONFIG  \
  --v=1 > $K8S_CONTROLLER_LOGS 2>&1 &
  echo "done"
}

function f_kill_of_process {
  if [ "$ARG_2" == "all" ]; then
      echo "Kill of All Server..." && sleep 1
      kill -9 $K8SM_API_SERVER_PID \
      $K8S_SCHEDULER_SERVER_PID \
      $K8S_CONTROLLER_SERVER_PID
      echo "done"

  elif [[ "$ARG_2" == "a" || "$ARG_2" == "api" ]]; then
      echo "Kill of API Server..." && sleep 1
      kill -9 $K8SM_API_SERVER_PID
      echo "done"

 elif [[ "$ARG_2" == "s" || "$ARG_2" == "sd" ]]; then
      echo "Kill of Scheduler..." && sleep 1
      kill -9 $K8SM_SCHEDULER_SERVER_PID
      echo "done"

 elif [[ "$ARG_2" == "c" || "$ARG_2" == "cm" ]]; then
      echo "Kill of Controller Manager..." && sleep 1
      kill -9 $K8SM_CONTROLLER_SERVER_PID
      echo "done"

  else
      echo "Not found PIDs"
  fi
}

function f_help {
  echo "Usage: $ARG_0 [Options] [Arguments]"
  echo
  echo "- Options"
  echo "a, api		: apiserver"
  echo "s, sd		: scheduler"
  echo "c, cm		: controller manager"
  echo "k, kill		: kill of process"
  echo
  echo "- Arguments"
  echo "s, start	: Start commands"
  echo "m, manual	: Manual commands"
  echo
  echo "all		: kill of all server (k or kill option only.)"
  echo "		ex) $ARG_0 k all or $ARG_0 kill all"
  echo
  echo "a, api		: kill of apiserver (k or kill option only.)"
  echo "		ex) $ARG_0 k a or $ARG_0 kill api"
  echo
  echo "s, sd		: kill of scheduler (k or kill option only.)"
  echo "		ex) $ARG_0 k s or $ARG_0 kill sd"
  echo
  echo "c, cm		: kill of controller manager (k or kill option only.)"
  echo "		ex) $ARG_0 k c or $ARG_0 kill cm"
  echo
}

# Main
ARG_0="$0"
ARG_1="$1"
ARG_2="$2"

case ${ARG_1} in
  a|api)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_apiserver

    elif [[ "$ARG_2" == "m"  ||  "ARG_2" == "manual" ]]; then
        f_apiserver_manual

    else
        f_help
    fi
  ;;

  s|sd)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_scheduler

    elif [[ "$ARG_2" == "m"  ||  "ARG_2" == "manual" ]]; then
        f_scheduler_manual

   else
       f_help
   fi
  ;;

  c|cm)
    if [[ "$ARG_2" == "s" || "$ARG_2" == "start"  ]]; then
        f_controller_manager

    elif [[ "$ARG_2" == "m"  ||  "ARG_2" == "manual" ]]; then
        f_controller_manager_manual

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
