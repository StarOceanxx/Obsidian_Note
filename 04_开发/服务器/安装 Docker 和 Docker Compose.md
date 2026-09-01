清理旧版本，避免后续出现兼容性问题
``` bash
yum remove -y docker* containerd.io podman* runc
```
# 官方脚本安装
一键安装 Docker 与 Docker Compose
``` bash
curl -fsSL https://get.docker.com | sh
```

 配置普通用户免 sudo 权限
``` bash
 sudo usermod -aG docker $USER 
 newgrp docker
```

验证安装是否成功
``` bash
# 验证 Docker
docker version

# 验证 Docker Compose（新版 V2 命令中间是空格，无短横线）
docker compose version
```

配置镜像加速
``` bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF
# 重载配置并重启 Docker 服务
sudo systemctl daemon-reload
sudo systemctl restart docker
```
# 阿里镜像安装
安装必要工具
``` bash
sudo dnf install -y yum-utils
```

添加阿里云 Docker CE 仓库
``` bash
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

手动编辑仓库文件，将 `rocky` 替换为 `centos`
``` bash
sudo sed -i 's|rocky/9|centos/9|g' /etc/yum.repos.d/docker-ce.repo
```

 清理缓存并重新生成元数据
``` bash
sudo dnf clean all
sudo dnf makecache
```

安装Docker
``` bash
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

设置自启动
``` bash
sudo systemctl start docker
sudo systemctl enable docker
docker version
```