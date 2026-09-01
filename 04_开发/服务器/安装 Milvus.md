# 检查硬件环境

``` bash
# CPU
# 精简
nproc
#详细 
lscpu

# 内存
free -h

# 硬盘
lsblk -d -o name,rota,model
```

# 下载并配置 Docker Compose 文件
``` bash
# 创建 Milvus 工作目录
mkdir -p /opt/milvus && cd /opt/milvus

# 下载官方最新 Standalone 版 docker-compose.yml
wget https://github.com/milvus-io/milvus/releases/download/v2.5.27/milvus-standalone-docker-compose.yml -O docker-compose.yml
```

# 配置镜像加速
已有配置
``` bash
vim /etc/docker/daemon.json

# 写入配置
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.xuanyuan.me"
  ]
}

# 重启服务使配置生效
systemctl daemon-reload 
systemctl restart docker

# 验证配置是否生效
docker info | grep -A 5 "Registry Mirrors"
```

未有配置
``` bash
mkdir -p /etc/docker 
touch /etc/docker/daemon.json

# 写入配置
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.xuanyuan.me"
  ]
}
EOF

# 重启服务使配置生效
systemctl daemon-reload 
systemctl restart docker

# 验证配置是否生效
docker info | grep -A 5 "Registry Mirrors"
```

# 启动 Milvus 服务
``` bash
# 后台启动所有服务（etcd + minio + milvus-standalone）
docker compose up -d

# 查看服务状态
docker compose ps
```

# 验证服务是否正常
``` bash
# 查看 Milvus 主容器日志 
docker logs -f milvus-standalone 
# 等待出现 "Welcome to use Milvus!" 字样，表示启动成功
```

# 开放端口

# 访问
WebUI地址：
	http://<ip>:9091/webui/
