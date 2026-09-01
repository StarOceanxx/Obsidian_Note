# 安装

``` powershell
scoop install mise
```
## 添加Shims到环境变量Path中
Shims是一种用来拦截和动态路由命令的机制。
## 添加 mise 激活脚本
### PowerShell 激活方式
``` powershell
notepad $PROFILE

New-Item -Path $PROFILE -Type File -Force
```
在打开的记事本中，粘贴以下内容并保存
``` ps1
# 修复版激活脚本：强制转换为字符串并忽略非致命错误 
$activateScript = (& mise activate pwsh 2>$null | Out-String) 
if ($activateScript -and $activateScript.Trim() -ne "") { 
	try { 
		Invoke-Expression $activateScript 
	} catch { 
		Write-Warning "mise 激活脚本执行出错，请检查 mise 版本或配置。" 
	} 
}
```
### cmd激活方式

``` powershell
#写入注册表
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d 'mise activate pwsh >> "%USERPROFILE%\cmdrc.cmd"' /f

#验证是否写入成功
reg query "HKCU\Software\Microsoft\Command Processor" /v AutoRun
```

## 修改配置
``` powershell
# 1. 设置工具与语言版本的安装位置（如 node, python, java 等）
[System.Environment]::SetEnvironmentVariable("MISE_DATA_DIR","D:\software_dev_tool\mise\data", "User")

# 2. 设置全局配置文件路径（config.toml） 
[System.Environment]::SetEnvironmentVariable("MISE_CONFIG_DIR","D:\software_dev_tool\mise\config", "User") 

# 3. 设置下载缓存路径 
[System.Environment]::SetEnvironmentVariable("MISE_CACHE_DIR","D:\software_dev_tool\mise\cache", "User") 

# 4. 设置运行时状态路径 
[System.Environment]::SetEnvironmentVariable("MISE_STATE_DIR","D:\software_dev_tool\mise\state", "User")
```
## Mise指令
mise doctor
mise ls
mise ls <tool[node | java]> --json
# 安装Node
``` powershell
# 设置镜像源
mise settings node.mirror_url=https://mirror.nju.edu.cn/nodejs-release/

mise use -g node@22

npm config set registry https://registry.npmmirror.com

npm config get registry

# 设置npm的全局安装路径
npm config set prefix 'D:\npm-global'  
```

# 安装JDK
``` powershell
# 安装并设置为全局默认版本,java需指定发行版（temurin）
mise use -g java@temurin-8
```

# 安装Python

``` cmd
mise use python@3.11
```