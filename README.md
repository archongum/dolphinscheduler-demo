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


### MySQL


Deploy

```sh
docker run -d --restart always \
--name mysql --hostname mysql --network network-aws \
-e MYSQL_ROOT_PASSWORD="root123" \
-e MYSQL_DATABASE="default" \
-e MYSQL_USER="dba" \
-e MYSQL_PASSWORD="dba123" \
mysql/mysql-server:8.0.24
```

Verify

```sh
docker exec -it mysql sh -c 'mysql -udba -pdba123 default -e "select current_date"'

# mysql cli
docker exec -it mysql sh -c 'mysql -udba -pdba123 default'
```

## 2_dolphinscheduler

### dolphinscheduler-tools

```sh
# Create and enter container
docker run -it --rm \
--name tools --hostname tools --network network-aws \
-e DATABASE="mysql" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/default" \
-e SPRING_DATASOURCE_USERNAME="dba" \
-e SPRING_DATASOURCE_PASSWORD="dba123" \
apache/dolphinscheduler-tools:3.1.5

# Download MySQL JDBC Driver
export MYSQL_JDBC_VERSION=9.1.0
curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
-o /opt/dolphinscheduler/tools/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar

# Initiate schema
tools/bin/upgrade-schema.sh
```

### dolphinscheduler-api

```sh
# Create and enter container
## Disable kubernetes detection: SPRING_CLOUD_KUBERNETES_ENABLED=false
docker run -it --rm \
-p 12345:12345 \
--entrypoint bash \
--name tools --hostname tools --network network-aws \
-e DATABASE="mysql" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/default" \
-e SPRING_DATASOURCE_USERNAME="dba" \
-e SPRING_DATASOURCE_PASSWORD="dba123" \
-e REGISTRY_ZOOKEEPER_CONNECT_STRING="zk-1:2181,zk-2:2181,zk-3:2181" \
-e SPRING_CLOUD_KUBERNETES_ENABLED="false" \
apache/dolphinscheduler-api:3.1.5

# Download MySQL JDBC Driver
export MYSQL_JDBC_VERSION=9.1.0
curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
-o /opt/dolphinscheduler/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar

# Start Service
bin/start.sh
```

### dolphinscheduler-master

```sh
# Create and enter container
## Disable kubernetes detection: SPRING_CLOUD_KUBERNETES_ENABLED=false
docker run -it --rm \
-p 12345:12345 \
--entrypoint bash \
--name tools --hostname tools --network network-aws \
-e DATABASE="mysql" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/default" \
-e SPRING_DATASOURCE_USERNAME="dba" \
-e SPRING_DATASOURCE_PASSWORD="dba123" \
-e REGISTRY_ZOOKEEPER_CONNECT_STRING="zk-1:2181,zk-2:2181,zk-3:2181" \
-e SPRING_CLOUD_KUBERNETES_ENABLED="false" \
apache/dolphinscheduler-master:3.1.5

# Download MySQL JDBC Driver
export MYSQL_JDBC_VERSION=9.1.0
curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
-o /opt/dolphinscheduler/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar

# Start Service
bin/start.sh
```

### dolphinscheduler-worker

```sh
# Create and enter container
## Disable kubernetes detection: SPRING_CLOUD_KUBERNETES_ENABLED=false
docker run -it --rm \
-p 12345:12345 \
--entrypoint bash \
--name tools --hostname tools --network network-aws \
-e DATABASE="mysql" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/default" \
-e SPRING_DATASOURCE_USERNAME="dba" \
-e SPRING_DATASOURCE_PASSWORD="dba123" \
-e REGISTRY_ZOOKEEPER_CONNECT_STRING="zk-1:2181,zk-2:2181,zk-3:2181" \
-e SPRING_CLOUD_KUBERNETES_ENABLED="false" \
apache/dolphinscheduler-worker:3.1.5

# Download MySQL JDBC Driver
export MYSQL_JDBC_VERSION=9.1.0
curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
-o /opt/dolphinscheduler/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar

# Start Service
bin/start.sh
```

### dolphinscheduler-alert-server

```sh
# Create and enter container
## Disable kubernetes detection: SPRING_CLOUD_KUBERNETES_ENABLED=false
docker run -it --rm \
-p 12345:12345 \
--entrypoint bash \
--name tools --hostname tools --network network-aws \
-e DATABASE="mysql" \
-e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/default" \
-e SPRING_DATASOURCE_USERNAME="dba" \
-e SPRING_DATASOURCE_PASSWORD="dba123" \
-e REGISTRY_ZOOKEEPER_CONNECT_STRING="zk-1:2181,zk-2:2181,zk-3:2181" \
-e SPRING_CLOUD_KUBERNETES_ENABLED="false" \
apache/dolphinscheduler-alert-server:3.1.5

# Download MySQL JDBC Driver
export MYSQL_JDBC_VERSION=9.1.0
curl -L "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_JDBC_VERSION}/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar" \
-o /opt/dolphinscheduler/libs/mysql-connector-j-${MYSQL_JDBC_VERSION}.jar

# Start Service
bin/start.sh
```
