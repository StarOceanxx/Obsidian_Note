创建 SSH
``` bash
# 查看是否有ssh秘钥
ls -al ~/.ssh
# 生成新的 SSH 密钥
ssh-keygen -t ed25519 -C "<邮箱地址>"
# 将生成公钥复制到github的SSH设置里面

# 测试连接
ssh -T git@github.com
```