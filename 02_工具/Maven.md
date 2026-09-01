使用命令
mvn clean compile --offline

idea Maven插件重新加载所有Maven项目

强制更新快照
``` batch
mvn clean compile -U
```

递归删除所有
``` batch
cd /d D:\software_dev_tool\maven_repo

:: 删除所有 lastUpdated 文件
del /s /q *.lastUpdated

:: 删除所有 _remote.repositories 文件
del /s /q _remote.repositories
```



删除maven仓库缓存文件

``` batch
cd /d D:\software_dev_tool\maven_repo\cn\com\zetatech\cloud\sf\service-common\3.5.7-SNAPSHOT
del /s /q *.lastUpdated
del /s /q _remote.repositories
del /s /q resolver-status.properties
```


``` batch
cd /d D:\software_dev_tool\maven_repo\cn\com\zetatech\cloud\sf
del /s /q *.lastUpdated
del /s /q _remote.repositories
```

执行离线编译
``` batch
mvn clean compile --offline -f pom.xml
```

衍生点：路由问题
``` batch
ping 10.10.105.200

tracert 10.10.105.200

```