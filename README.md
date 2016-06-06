Dockerfile - A Kubernetes Framework for Apache Mesos (test only)
============================================================================
![0]
Fig 1. The architecture diagram of Kubernetes Framework for Apache Mesos

# - What is kubernetes mesos framework?
K8SM(Kubernetes Mesos)는 Apache Mesos에서 Google의 Kubernetes를 사용 할 수 있도록 만들어진 mesos framework 입니다.

K8SM framework를 물리 서버 1대 만으로도 실제와 같은 구성 및 테스트를 해볼 수 있도록 만들어 봤습니다.( 테스트 용도로만 사용하시면 됩니다.)

Apache Mesos와 Kubernetes의 대해서는 아래 링크 또는 구글링을 통해 참고 하시기 바랍니다.

Apache Mesos:
https://www.yongbok.net/blog/apache-mesos-cluster-resource-management/

Google kubernetes:
https://www.yongbok.net/blog/google-kubernetes-container-cluster-manager/

#### - Clone
Github 저장소에서 Dockerfile을 받아 옵니다.
```sh
root@ruo91:~# git clone https://github.com/ruo91/docker-kubernetes-mesos /opt/docker-kubernetes-mesos
```

#### - Build
Kubernetes v1.0 버전이 release 되면서 K8SM가 kubernetes 저장소의 contrib/mesos 디렉토리로 통합 되었습니다.
Kubernetes 0.x 버전대에서는 분산 환경에서 연동 부분에서 문제가 있었는데, v1.0+ 부터는 해결 되었으나, pods pull까지만 구현 되어있습니다.
이 부분은 차후 해결 될것으로 보입니다.

Kubernetes 저장소에서 받아와 빌드 합니다.
(KUBERNETES_CONTRIB 변수를 설정 하지 않으면 빌드시에 km 명령어가 빌드 되지 않습니다.)
```sh
root@ruo91:~# git clone https://github.com/GoogleCloudPlatform/kubernetes /opt/kubernetes
root@ruo91:~# cd /opt/kubernetes
root@ruo91:~# export KUBERNETES_CONTRIB=mesos
root@ruo91:~# make release
```
빌드가 완료 되면 테스트로 사용 될 Docker Images를 빌드 해야 합니다.
이를 위해 빌드와 실행이 쉽도록 쉘 스크립트를 따로 만들어 두었습니다. 사용 방법은 아래와 같습니다.
```sh
root@ruo91:~# cd /opt/docker-kubernetes-mesos
root@ruo91:~# docker-k8sm.sh -h
```
```sh
Usage: ./docker-k8sm.sh [Options]

- Options
b, build     : Build images
r, run       : Run containers
rm           : Stop and remove container & images
h, help      : Help
```

etcd, mesos master, kubernetes mesos, kubernetes minion 을 빌드 합니다.
```sh
root@ruo91:~# docker-k8sm.sh build
```

#### - Run
etcd, mesos master, kubernetes mesos, kubernetes minion을 실행 합니다.
```sh
root@ruo91:~# docker-k8sm.sh run
```

실행과 동시에 각각의 Container들은 pipework를 통해 아래와 같이 구성 됩니다.
```sh
HostName                     CIDR
etcd-0                   172.17.1.1/16
etcd-1                   172.17.1.2/16
etcd-2                   172.17.1.3/16
mesos-master-0           172.17.1.4/16
mesos-master-1           172.17.1.5/16
mesos-master-2           172.17.1.6/16
kubernetes-mesos         172.17.1.7/16
kubernetes-minion-0      172.17.1.8/16
kubernetes-minion-1      172.17.1.9/16
kubernetes-minion-2      172.17.1.10/16
kubernetes-minion-3      172.17.1.11/16
```

#### - Daemon start
##### - ETCD
3개의 etcd container는 아래 명령어를 통해 자동으로 클러스터링 설정이 되며 실행 됩니다.
```sh
root@ruo91:~# docker exec etcd-0 /bin/bash etcd-cluster.sh
```
```sh
Usage: etcd-cluster.sh [Options] [Arguments]

- Options
e, etcd		: etcd
k, kill		: kill of process

- Arguments
s, start	: Start commands
m, manual	: Manual commands
e, etcd		: kill of etcd (k or kill option only.)
		ex) etcd-cluster.sh k e or etcd-cluster.sh kill etcd
```
```sh
root@ruo91:~# docker exec etcd-0 /bin/bash etcd-cluster.sh etcd start
root@ruo91:~# docker exec etcd-1 /bin/bash etcd-cluster.sh etcd start
root@ruo91:~# docker exec etcd-2 /bin/bash etcd-cluster.sh etcd start
```
```sh
Start ETCD...
done
```

##### - Apache Mesos Master
Mesos Master에 ZooKeeper가 설치 되어 있으므로, ZooKeeper를 먼저 실행 합니다.
```sh
root@ruo91:~# docker exec kubernetes-minion-0 /bin/bash mesos.sh
Usage: mesos.sh [Options] [Arguments]

- Options
zk, zookeeper      : Start ZooKeeper
mm, mesos-master   : Start Mesos Master
ms, mesos-slave    : Start Mesos Slave
k, kill            : kill of process

- Arguments
s, start           : Start commands
m, manual          : Manual commands

zk, zookeeper      : kill of zookeeper (k or kill option only.)
                     ex) mesos.sh k zk or mesos.sh kill zookeeper

mm, mesos-master   : kill of mesos-master (k or kill option only.)
                     ex) mesos.sh k mm or mesos.sh kill mesos-master

ms, mesos-slave    : kill of mesos-slave (k or kill option only.)
                     ex) mesos.sh k ms or mesos.sh kill mesos-slave
```
```sh
root@ruo91:~# docker exec mesos-master-0 /bin/bash mesos.sh zk start
root@ruo91:~# docker exec mesos-master-1 /bin/bash mesos.sh zk start
root@ruo91:~# docker exec mesos-master-2 /bin/bash mesos.sh zk start
```
```sh
Start ZooKeeper...
done
```

이후 Mesos Master를 실행 합니다.
```sh
root@ruo91:~# docker exec mesos-master-0 /bin/bash mesos.sh mm start
root@ruo91:~# docker exec mesos-master-1 /bin/bash mesos.sh mm start
root@ruo91:~# docker exec mesos-master-2 /bin/bash mesos.sh mm start
```
```sh
Start Mesos Master...
done
```

##### - Kubernetes Minion
기존 Kubernetes에서 Minion은 kube-proxy와 kubelet을 실행 하는데,
K8SM에서는 Mesos가 이를 제어 하므로 Mesos Slave만 실행 하면 됩니다.
```sh 
root@ruo91:~# docker exec kubernetes-minion-0 /bin/bash mesos.sh ms start
root@ruo91:~# docker exec kubernetes-minion-1 /bin/bash mesos.sh ms start
root@ruo91:~# docker exec kubernetes-minion-2 /bin/bash mesos.sh ms start
root@ruo91:~# docker exec kubernetes-minion-3 /bin/bash mesos.sh ms start
```
```sh
Start Mesos Slave...
done
```

##### - Kubernetes Mesos Framework
K8SM에서는 기존의 Kubernetes가 가지고 있는 API Server, Scheduler, Controller Manager를 가지고 있습니다.
다만, km 명령어를 통해 실행 하는데, 일일이 실행하기 귀찮으니 쉘 스크립트를 만들어 두었으므로 아래와 같이 실행 하면 됩니다.
```sh
root@ruo91:~# docker exec kubernetes-mesos /bin/bash k8sm.sh
```
```sh
Usage: k8sm.sh [Options] [Arguments]

- Options
a, api		: apiserver
s, sd		: scheduler
c, cm		: controller manager
k, kill		: kill of process

- Arguments
s, start	: Start commands
m, manual	: Manual commands

all		: kill of all server (k or kill option only.)
		ex) k8sm.sh k all or k8sm.sh kill all

a, api		: kill of apiserver (k or kill option only.)
		ex) k8sm.sh k a or k8sm.sh kill api

s, sd		: kill of scheduler (k or kill option only.)
		ex) k8sm.sh k s or k8sm.sh kill sd

c, cm		: kill of controller manager (k or kill option only.)
		ex) k8sm.sh k c or k8sm.sh kill cm
```

API Server 실행
```sh
root@ruo91:~# docker exec kubernetes-mesos /bin/bash k8sm.sh api start
```
```sh
Start API Server...
done
```

Controller Manager 실행
```sh
root@ruo91:~# docker exec kubernetes-mesos /bin/bash k8sm.sh cm start
```
```sh
Start Controller Manager...
done
```

Scheduler 실행
```sh
root@ruo91:~# docker exec kubernetes-mesos /bin/bash k8sm.sh sd start
```
```sh
Start Scheduler...
done
```


#### - Test
kubernetes-mesos container에서 kubectl 명령어를 통해 K8SM 스케줄러가 정상 등록 되어있는지 확인 합니다.
```sh
root@ruo91:~# docker exec kubernetes-mesos kubectl get services
```
```sh
NAME             LABELS                                    SELECTOR   IP(S)         PORT(S)     AGE
k8sm-scheduler   component=scheduler,provider=k8sm         <none>     10.0.18.129   10251/TCP   33s
kubernetes       component=apiserver,provider=kubernetes   <none>     10.0.0.1      443/TCP     1m
```

예제 Nginx YAML 파일을 통해 Pods를 구성 해봅니다.
```sh
root@ruo91:~# docker exec kubernetes-mesos kubectl create -f /opt/nginx.yaml
```
```sh
pods/nginx
```

Pods를 확인 해봤을때, STATUS 부분에 Pending 상태로 되어있는 경우, Docker Images를 받아오는 중이라고 생각 하시면 됩니다.
Running의 경우 Container가 실행 중이라는 뜻입니다.
```sh
root@ruo91:~# docker exec kubernetes-mesos kubectl get pods
```
```sh
NAME      READY     STATUS    RESTARTS   AGE
nginx     1/1       Running   0          14s
```

#### - Web UI
K8SM(Kubernetes Mesos)에서는 Mesos와 Kubernetes의 조합이므로,
Mesos Master UI, Kubernetes UI를 지원합니다. 각각의 기본 포트는 아래와 같습니다.
```sh
kubernetes: 8080
mesos master: 5050
```

Nginx를 사용 중인 경우 Reverse Proxy로 연결 해줄 수 있습니다.
```sh
root@ruo91:~# nano /etc/nginx/nginx.conf
```
```sh
# Mesos master web ui
server {
    listen  80;
    server_name mesos.yongbok.net;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://172.17.1.4:5050;
        client_max_body_size 10M;
    }
}

# Kubernetes apiserver web ui
server {
    listen  80;
    server_name kubernetes.yongbok.net;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://172.17.1.7:8080;
        client_max_body_size 10M;
    }
}
```
```sh
root@ruo91:~# nginx -t 
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
root@ruo91:~# nginx -s reload
```

Mesos Master WEB UI
----------------------
![Mesos Master WEB UI][1]

Mesos Master WEB UI - Framework
----------------------------------
![Mesos Master WEB UI Framework][2]

Mesos Master WEB UI - Framework ID
-------------------------------------
![Mesos Master WEB UI Framework ID][3]

Kubernetes Web UI
------------------
![Kubernetes Web UI][4]

Kubernetes Web UI - Pods
-------------------------
![Kubernetes Web UI Pods][5]

Thanks. :-)
[0]: http://cdn.yongbok.net/ruo91/architecture/k8s/kubernetes_mesos_architecture_v1.x.png
[1]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui.png
[2]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui_framework.png
[3]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui_framework_id.png
[4]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_apiserver.png
[5]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_apiserver_pods.png
