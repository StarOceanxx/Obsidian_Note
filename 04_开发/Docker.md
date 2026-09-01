``` bash
# 查看目前启动的所有容器
docker ps 

# 查看容器信息
docker inspect <容器名或容器ID>

# 查看镜像信息
docker image inspect <容器名:TAG 或 容器ID>

# 查看镜像历史
docker history <容器名或容器ID>

```


查看容器内的服务配置
``` bash
 # 进入容器内部
docker exec -it <容器名或容器ID> /bin/bash

# 进入容器后，使用 cat 或 vi 查看配置文件（以 Nginx 为例）
cat /etc/nginx/nginx.conf
```

通过runlike查看容器启动命令
[[安装 runlike]]
``` bash
runlike <容器名>
```