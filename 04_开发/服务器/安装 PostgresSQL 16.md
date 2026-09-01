``` bash
# 根据linux不同的发行版本，用不同的包管理工具下载。
# RedHat 8.4
# 添加 PostgreSQL 官方 YUM 仓库（RHEL 8 专用）
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# 如果系统自带PostgreSQL模块，需要禁用
# 禁用系统默认的 PostgreSQL 模块
sudo dnf -qy module disable postgresql

# 安装 PostgreSQL 16 服务端核心包和 contrib 扩展包
sudo dnf install -y postgresql16-server postgresql16-contrib

# 初始化数据库集群
sudo /usr/pgsql-16/bin/postgresql-16-setup initdb

# 启动服务并设置开机自启
sudo systemctl enable --now postgresql-16

# 验证服务运行状态
sudo sysctemctl status postgresql-16

# 系统安装后会自动创建 postgres 操作系统用户和数据库超级用户。需为其设置登录密码：
# 切换到 postgres 用户并进入 psql 命令行
sudo -u postgres psql 

# 在 psql 中修改密码（请将密码替换为强密码）
ALTER USER postgres WITH PASSWORD '你的强密码'; 

# 退出 psql
\q

# PostgreSQL 默认只监听 localhost（127.0.0.1），需修改配置以允许外部连接。
# 编辑主配置文件
sudo vi /var/lib/pgsql/16/data/postgresql.conf

# 找到并修改以下配置
listen_addresses = '*'
post = 5432

# 修改后重启服务使配置生效
sudo systemctl restart postgresql-16

# 配置防火墙放行端口
# 放行端口
sudo firewall-cmd --permanent --add-port=5432/tcp

# 重载防火墙配置
sudo firewall-cmd --reload

# 验证端口是否已放行
sudo firewall-cmd --list-ports

# 修改pg_hba.conf允许远程认证
# pg_hba.conf 控制哪些主机、用户和数据库可以连接数据库
# 编辑认证配置文件
sudo vi /var/lib/pgsql/16/data/pg_hba.conf

# 在文件末尾添加以下行，允许远程 IP 通过密码认证连接
host    all             all             0.0.0.0/0               md5

**参数说明**： 
- host：表示 TCP/IP 连接。 
- all：允许连接所有数据库。 
- all：允许连接的用户名（可替换为具体用户名）。 
- 0.0.0.0/0：允许所有 IPv4 地址（生产环境建议限制为特定网段，如 192.168.1.0/24）。 
- md5：使用密码哈希认证。也可使用 scram-sha-256 更安全。
  
# 修改后重新加载配置
sudo systemctl reload postgresql-16
```