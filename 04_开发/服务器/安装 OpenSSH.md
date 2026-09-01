
``` bash
# 下载OpenSSH服务器
sudo dnf install -y openssh-server

# 启动SSH服务并设置开机自启
sudo systemctl enable --now sshd

# 放行SSH端口
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```