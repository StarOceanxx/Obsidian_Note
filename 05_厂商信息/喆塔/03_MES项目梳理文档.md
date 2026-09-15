> 文档依据服务完整启动日志、停止日志、Nginx 代理配置、组件运行日志整理，用于开发、运维、新人培训参考

## 目录

1. 项目基础信息
2. 技术栈清单
3. 完整启动 & 停机时序流程
4. 请求调用全链路
5. 核心组件工作原理、优势、隐藏风险
6. 日常开发必备知识点
7. 生产运维重点排查清单

---

## 1. 项目基础信息

- 服务名称：`MES-OPERATION-SERVICE-DXX`
- 端口：6211
- 部署形态：Spring Cloud Netflix 微服务集群部署
- 数据库：Oracle
- 用途：MES 产线运营核心业务服务

## 2. 项目完整技术栈清单

### 基础框架

- Spring Boot 2.x
- Spring Cloud Netflix（Eureka、Feign、Ribbon、Hystrix）
- Spring Security + OAuth2（接口鉴权）
- Springfox Swagger2（API 文档）

### 数据层

- Mybatis-Plus
- dynamic-datasource 动态多数据源
- HikariCP 数据库连接池
- Quartz 2.3.2（集群定时任务）

### 中间件

- Spring Cloud Config 配置中心
- Eureka 注册中心
- RabbitMQ 消息队列
- Redis + Redisson（缓存、分布式锁）

### HTTP 通信

- OpenFeign（内部微服务调用）
- RestTemplate + OkHttp（第三方外部接口调用）
- Nginx 反向代理网关前置

### 其他组件

- Tibrv（产线设备消息通信）
- WPC 产线工位配置组件
- 自定义全局异常过滤器

## 3. 服务启动 & 停机标准时序
### 3.1 启动时序

1. JVM 启动，加载 bootstrap 配置
2. 连接 **Spring Cloud Config** 拉取远程配置；额外加载服务器 NFS 本地 yml 配置（本地配置优先级更高）
3. 日志框架初始化
4. 初始化 Tomcat 容器
5. Mybatis、Mapper 文件解析加载
6. HikariCP 初始化三组独立连接池
    
    - mes：MES 主业务库
    - erp：ERP 对接数据库
    - qzDS：Quartz 定时任务独立数据源
    
7. dynamic-datasource 多数据源路由就绪
8. Redisson 建立 Redis 连接，分布式锁可用
9. Feign 客户端、自定义请求拦截器初始化
10. RabbitMQ 建立连接、自动声明队列、启动消费者
11. Quartz 集群定时任务初始化、启动调度器
12. Spring Security OAuth2 过滤器链加载（Token 鉴权）
13. Eureka 客户端初始化，拉取注册中心全部服务实例
14. 服务注册至 Eureka，实例状态 `UP`
15. Tomcat 绑定 6211 端口，对外接收 HTTP 请求
16. Swagger 扫描所有 Controller 接口
17. Spring 容器启动完成
18. 业务自定义组件初始化：WPC 配置、自定义 Hystrix 并发策略

### 3.2 停机优雅关闭时序（Spring ShutdownHook）

1. 触发关闭钩子，主动向 Eureka 发起下线，状态变更 `UP → DOWN`
    
    > 【现象】Eureka 异步线程会短暂触发状态抖动：DOWN 再次短暂变回 UP
    
2. RabbitMQ 停止接收新消息，等待正在消费任务执行完成
3. 关闭 Spring @Async 全局线程池
4. Quartz 暂停任务调度，等待运行中 Job 结束，关闭 Quartz 数据库连接池
5. 销毁 Tibrv 产线消息客户端
6. 依次关闭 erp、mes 业务数据库连接池，销毁多数据源管理器
7. Eureka 客户端资源、心跳线程彻底销毁

## 4. 系统完整调用链路

### 4.1 前端接口请求链路

plaintext

```
前端 → Nginx /gw/ 反向代理
→ 路径重写 /gw/xxx → /xxx
→ 转发至 mes-operation-service:6211
→ SpringSecurity OAuth2过滤器链（解析Token、鉴权）
→ 自定义全局异常过滤器
→ Controller → Service
```

> Nginx 额外处理：重定向修正、Cookie 路径修正 `proxy_cookie_path`

### 4.2 内部微服务之间调用

plaintext

```
Service → OpenFeign接口 → Feign拦截器（传递上下文）
→ Ribbon负载均衡 → Hystrix线程池隔离
→ HTTP请求 → 目标微服务
```

### 4.3 调用外部第三方系统

plaintext

```
Service → RestTemplate(底层OkHttp) → 第三方接口
```

> ⚠️ Feign 拦截器与 RestTemplate 拦截器互相独立，上下文需要两套配置

### 4.4 异步消息流程

plaintext

```
业务代码 → RabbitMQ生产者发送消息
→ RabbitMQ服务端 → 当前服务Rabbit消费者
→ 执行业务消费逻辑
```

### 4.5 定时任务流程

plaintext

```
Quartz调度器 → 读取Oracle Quartz系统表
→ 通过数据库锁抢占任务（集群防重复执行）
→ 执行自定义Job（可注入Spring Bean）
```

## 5. 核心组件：工作原理、优势、隐藏风险

### 5.1 Spring Cloud Config 配置中心

**原理**

服务启动阶段远程拉取统一 yml 配置；支持本地 NFS 配置文件覆盖远程配置。

✅ 优势

集中管理所有环境配置，无需打包修改参数；区分 demo/prod 环境。

⚠️ 隐藏风险

1. 本地 NFS 配置优先级高于配置中心，参数冲突难以排查；
2. 默认不支持配置动态刷新，修改配置需要重启服务；
3. 启动阶段依赖配置中心，配置中心不可用会导致服务启动失败。

### 5.2 Eureka 注册中心（Netflix）

**原理**

服务启动注册 UP，持续 3s 心跳上报；其他服务定时拉取服务列表缓存本地；下线发送 DOWN 状态。

✅ 优势

微服务自动发现，不需要硬编码 IP；原生适配 Spring Cloud Netflix 体系。

⚠️ 隐藏风险

1. 停机时出现状态抖动 `UP→DOWN→UP`，上游 Ribbon 缓存未刷新，流量继续打到关闭实例；
2. Eureka 自我保护机制，网络波动时不会立刻剔除故障实例；
3. Ribbon 客户端本地缓存服务列表，存在最多 30s 延迟；
4. Ribbon 已进入维护模式，属于技术债务。
### 5.3 OpenFeign + Ribbon + Hystrix

**原理**

Feign 声明式接口封装 HTTP 调用；Ribbon 客户端负载均衡；Hystrix 线程池隔离、熔断降级。

自定义`HystrixConcurrencyStrategy`解决 ThreadLocal 上下文传递问题（token、租户信息）。

✅ 优势

代码简洁，面向接口编程；原生适配微服务；熔断防止雪崩。

⚠️ 隐藏风险

1. Feign 超时、Ribbon 超时、Hystrix 超时三套独立配置，极易混淆；
2. Feign 拦截器**不会作用于 RestTemplate**；两套 http 客户端上下文需要分别处理；
3. Hystrix 线程切换，不配置自定义策略会丢失登录上下文；
4. 熔断触发后如果降级逻辑不完善，业务报错。

> 区分：
> 
> Feign：上层声明式框架；OkHttp：底层连接通信组件；二者不是同级组件。

### 5.4 Quartz 集群定时任务（JobStoreTX）

**原理**

任务信息持久化 Oracle，集群多个实例通过数据库行锁争抢任务，保证同一个任务集群只执行一次；独立 Hikari 连接池操作 quartz 表。

✅ 优势

支持集群部署、任务持久化，服务重启任务不丢失；区别于 @Scheduled（单机任务）。

⚠️ 隐藏风险

1. 当前线程池仅 5 条线程，大量任务同时触发会排队阻塞；
2. 实例宕机重启，框架扫描中断任务，**存在任务重复执行风险，必须做幂等**；
3. Quartz 拥有独立数据库连接池，连接池参数需要单独配置；
4. 大批量任务触发时，qrtz_locks 表竞争激烈，调度延迟。

### 5.5 dynamic-datasource + HikariCP 多数据源

**原理**

维护 mes、erp 两套业务数据源 + quartz 独立数据源；通过注解`@DS`动态切换数据源。

✅ 优势

一套服务访问多个 Oracle 库，隔离业务；Hikari 高性能连接池。

⚠️ 隐藏风险

1. 未指定`@DS`会使用默认数据源，容易出现跨库 SQL 异常；
2. 停机销毁顺序不当，若任务未结束先关闭连接池会抛出数据库异常；
3. 三套独立连接池，连接总数需要合理管控，防止数据库连接耗尽。

### 5.6 RabbitMQ 消息队列

**原理**

异步解耦业务，生产者发送消息，消费者异步处理。

✅ 优势

削峰、异步处理耗时业务。

⚠️ 隐藏风险

1. 自动 ACK 模式下，服务强行关闭会丢失消息；建议开启手动 ACK；
2. 停机等待消费任务无超时限制，死循环消息会阻塞容器关闭；
3. 需要保证消费业务幂等，防止消息重复投递。

### 5.7 Spring Security OAuth2 鉴权过滤器

**原理**

所有 HTTP 请求经过过滤器链，解析请求头 Token，完成身份认证与权限校验。

✅ 优势

统一接口鉴权，集中管控访问权限。

⚠️ 隐藏风险

1. 过滤器执行顺序很关键，自定义过滤器顺序错误会导致鉴权失效；
2. Feign 调用内部接口必须透传 Token，否则权限拦截。

### 5.8 Nginx 前置反向代理

nginx

```
location /gw/ {
    rewrite ^/gw/(.*)$ /$1 break;
    proxy_pass http://10.10.105.80:70$uri$is_args$query_string;
    proxy_cookie_path / /gw/;
}
```

✅ 优势

统一路径前缀`/gw/`对外暴露，隐藏后端真实接口路径；修正重定向、Cookie 路径。

⚠️ 隐藏风险

路径重写、cookie 路径配置错误会导致登录 Cookie 失效、前端跳转 404。

## 6. 后期开发必须掌握核心知识点

### 6.1 微服务调用规范

1. **内部微服务调用 → Feign**；**外部第三方接口 → RestTemplate+OkHttp**
2. Feign 与 RestTemplate 拦截器隔离，链路追踪、租户 ID、Token 两套都要配置；
3. 远程调用超时参数：区分 Feign、Ribbon、Hystrix 三个配置，不要混淆。

### 6.2 定时任务开发规范

1. 集群环境**禁止使用 @Scheduled**，统一使用 Quartz；
2. 所有定时任务强制实现**幂等性**，防止重启后重复执行；
3. 评估任务执行时长，必要时调大 Quartz 工作线程数；
4. 禁止在定时任务执行长时间阻塞逻辑。

### 6.3 数据源使用规范

1. 访问 erp 库必须添加`@DS("erp")`，mes 业务库`@DS("mes")`；
2. Quartz 使用独立数据源，业务代码禁止直接操作 qrtz 系统表；
3. 事务场景下注意多数据源事务限制（分布式事务问题）。

### 6.4 消息队列开发规范

1. 消费方法做好幂等；
2. 重要业务开启手动 ACK；
3. 避免无限重试死信，配置死信队列。

### 6.5 配置相关

1. 参数优先级：服务器 NFS 本地 yml > Config 配置中心；排查参数不生效优先确认两层配置；
2. 修改配置中心参数默认需要重启服务。

### 6.6 发布与停机规范

1. 发布停机存在 Eureka 状态抖动，建议配置 Spring 优雅停机 + 容器 preStop 等待 30s；
2. 上线顺序：中间件就绪 → 服务启动；下线顺序：先摘除流量，再关闭服务。

### 6.7 异常排查定位关键词（日志检索）

- 数据库异常：`HikariDataSource`
- 微服务调用熔断超时：`Hystrix`
- MQ 消费异常：`SimpleMessageListenerContainer`
- 定时任务异常：`QuartzScheduler`
- 注册发现问题：`DiscoveryClient`
- 接口鉴权失败：`OAuth2AuthenticationProcessingFilter`

## 7. 现存架构风险优化建议

1. **Ribbon 技术债务**：长期规划逐步迁移至 Spring Cloud 原生 LoadBalancerClient；
2. **Eureka 停机流量抖动**：完善优雅停机配置，增加发布等待窗口；
3. **Quartz 线程池 5 个偏少**：根据任务并发量评估调优；
4. **所有异步任务、定时任务、MQ 消费统一强制幂等规范；**
5. RabbitMQ 消费者停机增加最大等待超时，避免容器无法关闭；
6. 梳理三层连接池（mes/erp/quartz）连接数量，防止 Oracle 连接数打满。



# modeling

接口定位

| 模块       | 功能        | API格式                                                                                                | 后端服务             | 后端包                                                                         | 后端类                |
| -------- | --------- | ---------------------------------------------------------------------------------------------------- | ---------------- | --------------------------------------------------------------------------- | ------------------ |
| modeling | 工厂建模-状态模型 | /dict/data/select?dataSource                                                                         | modeling         | cn.com.zetatech.cloud.sf.service.enhance.dict.controller.DictDataController | DictDataController |
|          |           | /dict/consts/HISTORY_QUERY_PERIOD                                                                    |                  |                                                                             |                    |
|          |           | http://10.10.105.80:81/gw/security/accountMgts/getLoggedInUser?appCode=ZetaMESModeling-Semi-Fab-ZJLX | security-servcie |                                                                             |                    |
|          |           | http://10.10.105.80:81/gw/security/accountMgts/xinxin.du/ZetaMESModeling-Semi-Fab-ZJLX/menus         | security-servcie |                                                                             |                    |









