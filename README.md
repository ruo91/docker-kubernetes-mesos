Dockerfile - A Kubernetes Framework for Apache Mesos (test only)
=====================================
![0]
Fig 1. The architecture diagram of Kubernetes Framework for Apache Mesos

# - What is kubernetes mesos framework?
---------------------------------------
K8SM(Kubernetes Mesos)는 Apache Mesos에서 Google의 Kubernetes를 사용 할 수 있도록 만들어진 mesos framework 입니다.

K8SM framework를 물리 서버 1대 만으로도 실제와 같은 구성 및 테스트를 해볼 수 있도록 만들어 봤습니다.( 테스트 용도로만 사용하시면 됩니다.)

Apache Mesos와 Kubernetes의 대해서는 아래 링크 또는 구글링을 통해 참고 하시기 바랍니다.

Apache Mesos:
https://www.yongbok.net/blog/apache-mesos-cluster-resource-management/

Google kubernetes:
http://www.yongbok.net/blog/google-kubernetes-container-cluster-manager/

#### - Clone
------------
Github 저장소에서 Dockerfile을 받아 옵니다.
```
root@ruo91:~# git clone https://github.com/ruo91/docker-kubernetes-mesos /opt/docker-kubernetes-mesos
```

#### - Build
------------
K8SM은 아직까지 분산 환경에서 동작을 하지 않기 때문에, 올인원 모드로 빌드해서 구성 하셔야 합니다.

동작 하지않는 이유는 로컬머신에서는 K8SM의 scheduler가 mesos master로 스케줄러를 등록이 가능하지만, 분산 환경에서는 아직 구현이 안되어있기 때문입니다.

추후 mesosphere 팀에서 이 기능이 구현이 되면, README.md 파일을 분산 환경으로 다시 수정하도록 하겠습니다.
```
root@ruo91:~# cd /opt/docker-kubernetes-mesos
root@ruo91:~# docker build --rm -t k8sm:all -f k8sm-all-in-one .
```
#### - Run
------------
K8SM framework의 컨테이너를 실행 합니다.
```
root@ruo91:~# docker run -d --name="k8sm" -h "k8sm" --privileged=true -v /dev:/dev k8sm:all
```

실행 순서는 다음과 같으며

zookeeper -> mesos-slave -> mesos-master -> etcd -> apiserver -> scheduler -> controller-manager

k8sm 컨테이너에 접속합니다.

SSH passwd: k8sm
```
root@ruo91:~# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' k8sm`
```
```
root@k8sm:~# service zookeeper start
root@k8sm:~# /etc/mesos/mesos-slave.sh
root@k8sm:~# /etc/mesos/mesos-master.sh
root@k8sm:~# /opt/etcd-cluster.sh
root@k8sm:~# /opt/api-server.sh
root@k8sm:~# /opt/scheduler.sh
root@k8sm:~# /opt/controller-manager.sh
```

# - Test
--------
이제 테스트를 위해 k8sm 컨테이너에 접속합니다.

SSH passwd: k8sm
```
root@ruo91:~# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' k8sm`
```

scheduler가 정상적으로 등록 되어있는지 확인 합니다.
```
root@k8sm:~# kubectl get services
NAME             LABELS                                    SELECTOR   IP            PORT
k8sm-scheduler   component=scheduler,provider=k8sm         <none>     10.0.104.63   10251
kubernetes       component=apiserver,provider=kubernetes   <none>     10.0.0.2      443
kubernetes-ro    component=apiserver,provider=kubernetes   <none>     10.0.0.1      80
```

Container의 이름은 nginx, Label은 nginx-cluster, Docker images는 ruo91 사용자의 nginx 이미지, 실행 갯수는 10개를 실행 해봅니다.
```
root@k8sm:~# kubectl run-container nginx -l name=nginx-cluster --image=ruo91/nginx --replicas=10
```
```
CONTROLLER   CONTAINER(S)   IMAGE(S)      SELECTOR          REPLICAS
nginx        nginx          ruo91/nginx   name=nginx-cluster   10
```

이제 Pods의 정보를 확인 해보면 아직까지는 Pending으로 되어 있습니다.
이는 Docker HUB 저장소에서 ruo91/nginx 이미지를 받아오는 중이라 생각 하면 됩니다.
```
root@k8sm:~# kubectl get pods -s 172.17.1.87:8080
POD           IP        CONTAINER(S)   IMAGE(S)      HOST                   LABELS            STATUS    CREATED
nginx-7izkd             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-c7ies             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-djc1q             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-j9qji             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-mtlqn             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-o9la3             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-qb27h             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-tmvvm             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-uzubf             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
nginx-yjrvu             nginx          ruo91/nginx   k8sm/   name=nginx-cluster   Pending   20 seconds
```
시간이 지나면 다음과 같이 Running으로 바뀌게 됩니다.
```
root@k8sm:~# kubectl get pods
```
```
POD           IP         CONTAINER(S)   IMAGE(S)      HOST                LABELS               STATUS    CREATED
nginx-7izkd   10.0.0.1   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-c7ies   10.0.0.5   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-djc1q   10.0.0.9   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-j9qji   10.0.0.4   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-mtlqn   10.0.0.10  nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-o9la3   10.0.0.6   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-qb27h   10.0.0.2   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-tmvvm   10.0.0.3   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-uzubf   10.0.0.8   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
nginx-yjrvu   10.0.0.7   nginx          ruo91/nginx   k8sm/172.17.1.177   name=nginx-cluster   Running   52 minutes
```

#### - Web UI
kubernetes: 8080
mesos master: 5050

```
root@ruo91:~# docker inspect -f '{{ .NetworkSettings.IPAddress }}' k8sm`
172.17.1.177
```
```
root@ruo91:~# nano /etc/nginx/nginx.conf
```
```
# Mesos master web ui
server {
    listen  80;
    server_name mesos.yongbok.net;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://172.17.177:8080;
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
        proxy_pass http://172.17.177:8080;
        client_max_body_size 10M;
    }
}
```
```
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
[0]: http://cdn.yongbok.net/ruo91/architecture/k8sm/The_architecture_diagram_of_Kubernetes_Framework_for_Apache_Mesos.png
[1]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui.png
[2]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui_framework.png
[3]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_mesos_web_ui_framework_id.png
[4]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_apiserver.png
[5]: http://cdn.yongbok.net/ruo91/architecture/k8sm/k8sm_apiserver_pods.png