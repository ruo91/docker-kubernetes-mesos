#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

ETCD_SERVER="http://127.0.0.1:4001"
ZK_SERVER="zk://127.0.0.1:2181"

MESOS_USER="root"
FRAMEWORK_NAME="kubernetes-mesos"

km scheduler \
--v=2 \
--address=127.0.0.1 \
--api_servers=127.0.0.1:8080 \
--mesos_user=$MESOS_USER \
--mesos_master=$ZK_SERVER \
--etcd_servers=$ETCD_SERVER \
--framework_name=$FRAMEWORK_NAME \
> /tmp/scheduler.log 2>&1 &
