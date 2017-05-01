---
title: MongoDB分片+副本集群模式部署
date: 2017-05-01 19:01:57
tags:
---
## 前言
* 近期因产品升级，业务扩展的需要，将MongoDB单机改换成集群模式，于是配合运维和测试的小伙伴一起验证MongDB集群，由于都没有使用过分片集群，而刚好我前一份工作中构搭建和应用过MongoDB副本集群，这次一起将副本+分片集群从头部署了一遍，将部署的整个过程记录如下。
## 1.集群环境
* 集群模式： 分片+副本
* 操作系统： Linux（以CentOS 6.5为例）
* 硬件：3台服务器（或3个VM）
## 2.拓扑图
![image](http://zxshen.win/top.jpg)
## 3.安装MongDB
* 创建/etc/yum.repos.d/mongodb-org-3.4.repo文件
```
[mongodb-org-3.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
```
* 执行安装命令
```
sudo yum install -y mongodb-org
```
* 在三台服务器上分别执行以上操作，安装好MongoDB

参考链接:https://docs.mongodb.com/manual/tutorial/install-mongodb-on-red-hat/

## 4.配置集群
### 4.1创建节点目录
```
mkdir -p /var/lib/mongodb/conf
mkdir -p /var/lib/mongodb/data/{shard1,shard2,shard3,config}
```
### 4.1创建节点配置
* 进入/var/lib/mongodb/conf目录下
```
cd /var/lib/mongodb/conf
```
* 把附件中的配置文件copy在/var/lib/mongodb/conf目录下
* 将/var/lib/mongodb结点目录复制到其它两台服务器中，目录一至
* 分别启动三台服务器中的结点
```
numactl --interleave=all mongod -f shard1.conf
numactl --interleave=all mongod -f shard2.conf
numactl --interleave=all mongod -f shard3.conf
numactl --interleave=all mongod -f configdb.conf
```
* 等三台服务器上的mongod都启动好了后，再分别启动mongos
```
numactl --interleave=all mongos -f mongos.conf
```
* 注：可以不用numactl --interleave=all 启动，但用numactl关闭NUMA特性,可以提升数据性能


### 4.3设置第一个分片集
* 进入服务器1第一个结点
```
mongo 172.16.16.1:10001/admin
```
* 定义副本集

```
config = { _id:"shard1", members:[
{_id:0,host:"172.16.16.1:10001",priority:1},
{_id:1,host:"172.16.16.2:10001",priority:2},
{_id:2,host:"172.16.16.3:10001",priority:3}
]
}
```
* 初始化副本集
```
rs.initiate(config);
```
### 4.4设置第二个分片集
* 进入服务器1第二个结点

```
mongo 172.16.16.1:10002/admin
```
* 定义副本集
```
config = { _id:"shard2", members:[
{_id:0,host:"172.16.16.1:10002",priority:2},
{_id:1,host:"172.16.16.2:10002",priority:3},
{_id:2,host:"172.16.16.3:10002",priority:1}
]
}
```
* 始化副本集
```
rs.initiate(config);
```
### 4.5设置第三个分片集
* 进入服务器1第三个结点

```
mongo 172.16.16.1:10003/admin
```
* 定义副本集
```
config = { _id:"shard3", members:[
{_id:0,host:"172.16.16.1:10003",priority:3},
{_id:1,host:"172.16.16.2:10003",priority:1},
{_id:2,host:"172.16.16.3:10003",priority:2}
]
}
```
* 始化副本集
```
rs.initiate(config);
```
### 4.6设置配置服务器副本集
进入服务器1配置结点
```
mongo 172.16.16.1:20000/admin
```
* 定义配置副本集
```
config = { _id:"configdb", configsvr: true, members:[
{_id:0,host:"172.16.16.1:20000",priority:3},
{_id:1,host:"172.16.16.2:20000",priority:2},
{_id:2,host:"172.16.16.3:20000",priority:1}
]
}
```
* 初始化配置副本集
```
rs.initiate(config);
```
### 4.7串联路由服务器与分片副本集
* 进入服务器1路由结点
```
mongo 172.16.16.1:30000/admin
```
* 设置分片配置
```
db.runCommand( { addshard : "shard1/172.16.16.1:10001,172.16.16.2:10001,172.16.16.3:10001"});
db.runCommand( { addshard : "shard2/172.16.16.1:10002,172.16.16.2:10002,172.16.16.3:10002"});
db.runCommand( { addshard : "shard3/172.16.16.1:10003,172.16.16.2:10003,172.16.16.3:10003"});
```
* 查看分片服务器配置
```
db.runCommand({listshards : 1 });
```
### 4.8创建管理用户
* 分别在**三台**服务器中的**primary主结点**创建管理员用户
```
use admin;
db.createUser( { "user" : "root",
"pwd": "password",
"roles" : [ { role: "clusterAdmin", db: "admin" },
{ role: "readWriteAnyDatabase", db: "admin" },
{ role: "root", db: "admin" },
"readWrite"
]
}
)
```
* 生成keyfile(每个进程的key file都保持一致)，在服务器中执行以下命令
```
cd /var/lib/mongodb/bin/
openssl rand -base64 753 > keyfile
chmod 600 keyfile
```
* 将生成的keyfile 通过scp拷贝到其他机器的/var/lib/mongodb/bin/目录下
* 防止scp过程中keyfile文件受损，导致不一至，可通过对比文件的MD5
```
md5sum keyfile
```
### 4.9重启集群
* 先停ballancer(部署的时候可以不管，但用于生产过程中，还是先停一下比较保险)
```
sh.stopBalancer()
```
* 关闭三台服务器的mongod和mongos服务
可以用 kill 15 pid 来关闭所有mongo

或者
```
killall mongos
killall mongod
```
* 修改三台服务器/var/lib/mongodb/conf下的配置文件，打开security 的keyfile注释，先启动mongod，再启动mongos
```
// 分别启动三台服务器中的结点
numactl --interleave=all mongod -f shard1.conf
numactl --interleave=all mongod -f shard2.conf
numactl --interleave=all mongod -f shard3.conf
numactl --interleave=all mongod -f configdb.conf

// 等三台服务器上的mongod都启动好了后，再分别启动mongos
numactl --interleave=all mongos -f mongos.conf
```
### 4.10设置分片键
* 集群默认是不自动分片，且集群中并非所有数据库和集合都需要采用分片模式，所以我们需要通过手动配置的方式来指定分片数据库和分片集合，其中关键在设置分片键(需要视业务设置)，在选定作为分片键的列必须创建索引，所有文档都必须有片键值，（且值不能为null），在集合分片完成后，才可以插入片键值为null的文档；
如果集合为空，mongodb 将在激活集合分片（sh.shardCollection）时自动创建索引

* 创建分片键
```
mongo 172.16.16.1:30000/admin
db.auth('root','password')
db.runCommand({"enablesharding":"IM"});
db.runCommand({"shardcollection":"IM.record","key":{"appid":1,"to":1}})
```
* 15.根据业务需要创建业务账号和密码
```
// 创建用户和密码：
use 数据库名
db.createUser({ user:"db_user",pwd:"password",roles:[{role:"readWrite", db: "db_name"}]})

// 访问集群
mongodb://db_user:password@172.16.16.1:30000,172.16.16.2:30000,172.16.16.3:30000/db_name?readPreference=primaryPreferred
```
## 5.完结
