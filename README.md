# dolphinscheduler-demo

## 1_preparation

### Common Network

```sh
docker network create --driver bridge network-aws
```

### ZooKeeper

Deploy

```sh
# zk
docker run -d --restart always \
--name zk-1 --hostname zk-1 --network network-aws \
-e ZOO_MY_ID=1 \
-e ZOO_SERVERS="server.1=zk-1:2888:3888;2181 server.2=zk-2:2888:3888;2181 server.3=zk-3:2888:3888;2181" \
zookeeper:3.9.3
# zk-2
docker run -d --restart always \
--name zk-2 --hostname zk-2 --network network-aws \
-e ZOO_MY_ID=2 \
-e ZOO_SERVERS="server.1=zk-1:2888:3888;2181 server.2=zk-2:2888:3888;2181 server.3=zk-3:2888:3888;2181" \
zookeeper:3.9.3
# zk-3
docker run -d --restart always \
--name zk-3 --hostname zk-3 --network network-aws \
-e ZOO_MY_ID=3 \
-e ZOO_SERVERS="server.1=zk-1:2888:3888;2181 server.2=zk-2:2888:3888;2181 server.3=zk-3:2888:3888;2181" \
zookeeper:3.9.3
```

Verify

```sh
for i in 1 2 3; do echo "zk-$i -> $(docker exec -it zk-$i sh -c 'echo srvr | nc localhost 2181 | grep -i mode')"; done
```
