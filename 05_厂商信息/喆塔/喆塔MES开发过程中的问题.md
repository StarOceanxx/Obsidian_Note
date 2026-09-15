# 后端
- **maven私服下载的问题**

- **docker_host这个变量的作用**
![[assets/Pasted image 20260728111842.png]]

- **需要generate_project.sh脚本文件**
![[assets/Pasted image 20260728141308.png]]

- **operation-mode下的model和operation-service下的model有什么区别**
![[assets/Pasted image 20260728142827.png]]

责任链模式工作流程
```
BehaviorWorkerProxy.doWork(cmd)
  │
  ├── 第1步：doExecutions(cmd)         ← 先执行 Execution
  │     │
  │     └── AbstractBehaviorTemplateExecution.execute(cmd)
  │           │
  │           ├── 1、 SELECT FOR UPDATE    ← 锁定行
  │           ├── 2、 doValidations(cmd)     ← 这里执行校验责任链
  │           ├── 3、 前置钩子             ← BO层业务校验添加进来
  │           ├── 4、 SELECT 补充数据
  │           ├── 5、 change() 业务逻辑
  │           ├── 6、 INSERT/UPDATE/DELETE
  │           └── 7、 INSERT 历史记录
  │
  └── 第2步：doActions(cmd)            ← 后执行 Action
        │
        └── 各种 Action.execute(cmd)
              └── 内部可能调 doExecutions(子命令)  ← 但 skipValidation=true
```

redis
![[assets/Pasted image 20260728225836.png]]

2点钟左右打不开测试网址了
![[assets/Pasted image 20260729141206.png]]


导入数据是不是没有履历


- 前端路由不到后端服务地址
![[assets/img_v3_02142_a574d1a3-1243-42c0-8156-8060180c54cg.jpg]]
eureka注册的ip地址不是VPN代理地址，导致没法转发路由
解决方案：修改项目注册到eureka的ip

swagger访问history服务的文档失败
![[assets/Pasted image 20260819170403.png]]

rabbitmq消息追踪，对已经消费的消息进行查看

docker容器的debug日志未持久化，当天重启后当天的日志被覆盖了
![[assets/Pasted image 20260824152631.png]]
# 前端

怎么精确的定位前端页面
前端页面有什么好用的调试方法
## modeling项目

![[assets/Pasted image 20260803134000.png]]
## operation项目
- 项目启动花了1分钟
- 切换工厂设置
![[assets/Pasted image 20260728114910.png]]



# 部署运维

部署后出现
``` bash
Eureka Down掉之后启动：
curl -X PUT "http://ip:port/eureka/apps/{application}/{instance}/status?value=UP"
示例：curl -X PUT "http://10.10.105.80:7010/eureka/apps/MES-MODELING-SERVICE-ZJLX/mes-modeling-service-zjlx-7fc59d7cf8-mr8bt:mes-modeling-service-zjlx:26210/status?value=UP"
```

# 操作管理
## 权限管控
个人和角色的菜单和操作权限的关系梳理表


![[assets/Pasted image 20260826120325.png]]