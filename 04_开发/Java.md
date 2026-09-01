# 责任链
Java 中的责任链模式（Chain of Responsibility Pattern）是一种行为型设计模式。它的核心思想是将请求的发送者和接收者解耦，使多个对象都有机会处理请求。这些处理对象被连接成一条链，请求会沿着这条链传递，直到有对象能够处理它为止。

### 核心角色

责任链模式通常包含以下三个主要角色：

1. **抽象处理者（Handler）**：定义一个处理请求的接口，通常包含一个指向下一个处理者的引用（后继者）。
2. **具体处理者（Concrete Handler）**：实现抽象处理者的处理方法。在接收到请求后，判断自己是否能处理该请求。如果能处理则执行相应逻辑；如果不能，则将请求转发给它的后继者。
3. **客户端（Client）**：负责创建处理链，并向链头的具体处理者对象提交请求。客户端不需要关心请求的处理细节和传递过程。

### 经典应用场景

在现实生活和软件开发中，责任链模式的应用非常广泛：

- **多级审批流程**：例如员工请假或采购审批，金额或天数较小时由部门主管审批，较大时由副总经理审批，更大时由总经理审批。
- **Web 请求过滤**：如 Java Web 开发中 Servlet 的 Filter 机制、Struts2 的拦截器等，请求在到达最终处理前会经过多个过滤器的预处理。
- **日志处理系统**：根据不同的日志级别（如 INFO、ERROR、FATAL），将日志分别输出到控制台、写入文件或发送短信报警。
- **异常处理机制**：在多层异常捕获中，根据异常的类型决定由哪一层进行处理。

### Java 代码示例

以下是一个基于“报销审批”场景的简单实现：
``` java
// 1. 定义处理器接口
public interface Approver {
    void processRequest(int amount);
    void setNextApprover(Approver nextApprover);
}

// 2. 具体处理者：组长（处理 <= 100 的报销）
public class TeamLeader implements Approver {
    private Approver nextApprover;

    @Override
    public void setNextApprover(Approver nextApprover) {
        this.nextApprover = nextApprover;
    }

    @Override
    public void processRequest(int amount) {
        if (amount <= 100) {
            System.out.println("Team leader approved the expense of $" + amount);
        } else if (nextApprover != null) {
            // 自己处理不了，交给下一个处理者
            nextApprover.processRequest(amount);
        } else {
            System.out.println("No one can approve the expense of $" + amount);
        }
    }
}

// 3. 具体处理者：经理（处理 <= 1000 的报销）
public class Manager implements Approver {
    private Approver nextApprover;

    @Override
    public void setNextApprover(Approver nextApprover) {
        this.nextApprover = nextApprover;
    }

    @Override
    public void processRequest(int amount) {
        if (amount <= 1000) {
            System.out.println("Manager approved the expense of $" + amount);
        } else if (nextApprover != null) {
            nextApprover.processRequest(amount);
        } else {
            System.out.println("No one can approve the expense of $" + amount);
        }
    }
}

// 4. 客户端测试
public class Client {
    public static void main(String[] args) {
        // 组装责任链：组长 -> 经理
        Approver teamLeader = new TeamLeader();
        Approver manager = new Manager();
        teamLeader.setNextApprover(manager);

        // 提交请求
        teamLeader.processRequest(80);   // 组长处理
        teamLeader.processRequest(500);  // 经理处理
        teamLeader.processRequest(5000); // 无人处理
    }
}
```
### 优缺点分析

**优点：**

- **解耦与灵活性**：将请求的发送者和接收者解耦，客户端无需知道具体由谁处理。同时，可以在运行时动态地改变链内的成员、调动次序或新增/删除责任。
- **符合单一职责原则**：每个处理类只关注自己该处理的工作，不该处理的传递给下一个对象，职责边界清晰。
- **符合开闭原则**：增加新的请求处理类时，无需修改原有代码，增强了系统的可扩展性。

**缺点：**

- **请求可能不被处理**：由于没有明确的接收者，如果链尾的处理者也无法处理，请求可能会一直传到链的末端而得不到处理（通常需要在链尾增加兜底逻辑）。
- **性能影响**：对于较长的职责链，请求的处理可能涉及多个对象，且链式调用会增加问题定位和调试的难度，对系统性能产生一定影响。
- **建链复杂性**：职责链建立的合理性依赖客户端来保证，如果设置错误（例如形成循环引用），可能会导致系统出错。

数据库行锁

Zookeep/spring cloud config/nacos
hibernate ORM spring Data JPA
netflix 
hystrix 
线程池隔离
不同外部调用使用独立线程池；A 服务卡住，不会拖垮整个应用线程
ribbon

```
问题：定时任务，Quartz集群如果有一台宕机，那么扫描到宕机的那台服务执行中断的任务，存在重复执行的风险，
解决方案：定时任务内部增加幂等判断，防止重复执行业务。
```

# 日志
MDC
tracer