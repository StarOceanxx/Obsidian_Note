# VPN

``` batch
REM 查看所有网络适配器信息
ipconfig/all 

:: 查看路由表
route print

:: 服务监听的 IP 和端口
netstat -ano | findstr :<服务端口>

:: 测试连通性
telnet <ip> <port>
```
``` powershell
# 查看服务路由规则
Find-NetRoute -RemoteIPAddress <ip>
```