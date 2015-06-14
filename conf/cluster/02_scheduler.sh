#!/bin/bash
K8SM=/opt/k8sm
PATH=$PATH:$K8SM

ETCD_SERVER="http://etcd-0:4001,http://etcd-1:4001,http://etcd-2:4001"
ZK_SERVER="zk://mesos-master-0:2181,mesos-master-1:2181,mesos-master-2:2181/mesos"
MESOS_USER="root"

km scheduler \
--v=2 \
--address=0.0.0.0 \
--api_servers=0.0.0.0:8080 \
--mesos_user=$MESOS_USER \
--mesos_master=$ZK_SERVER \
--etcd_servers=$ETCD_SERVER \
> /tmp/scheduler.log 2>&1 &
