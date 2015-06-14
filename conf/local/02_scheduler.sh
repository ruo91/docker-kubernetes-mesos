#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

ETCD_SERVER="http://127.0.0.1:4001"
ZK_SERVER="127.0.0.1:5050"
MESOS_USER="root"

km scheduler \
--v=2 \
--address=0.0.0.0 \
--api_servers=127.0.0.1:8080 \
--mesos_user=$MESOS_USER \
--mesos_master=$ZK_SERVER \
--etcd_servers=$ETCD_SERVER \
> /tmp/scheduler.log 2>&1 &
