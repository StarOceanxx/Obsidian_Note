# Claude Code
## 修改配置
修改用户目录下的~/.claude/settings.json
``` json
{
  "mcpServers": {},
  "agentDesktopManagedMcpServers": [],
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-thW2OtoeeG9Mo3dx5e7aFQ",
    "ANTHROPIC_BASE_URL": "https://litellm.southchips.net/",
	"ANTHROPIC_MODEL": "deepseek-v4-pro",
	"ANTHROPIC_DEFAULT_OPUS_MODEL": "sc-qwen-modes",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "API_TIMEOUT_MS": "300000",
	"CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4-flash",
	# 禁用不必要的官方遥测流量
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  },
  "effortLevel": "high"
}
```
### VS code使用插件
修改插件的settings.json
``` json
{
  // 1. 注入第三方 API 和模型分层环境变量
  "claudeCode.environmentVariables": [
    {
      "name": "ANTHROPIC_AUTH_TOKEN",
      "value": "你的API密钥"
    },
    {
      "name": "ANTHROPIC_BASE_URL",
      "value": "你的中转接口地址"
    },
    {
      "name": "ANTHROPIC_MODEL",
      "value": "deepseek-v4-pro"
    },
    {
      "name": "ANTHROPIC_DEFAULT_OPUS_MODEL",
      "value": "sc-qwen-modes"
    },
    {
      "name": "ANTHROPIC_DEFAULT_SONNET_MODEL",
      "value": "deepseek-v4-pro"
    },
    {
      "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",
      "value": "deepseek-v4-flash"
    },
    {
      "name": "API_TIMEOUT_MS",
      "value": "300000"
    },
    {
      "name": "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC",
      "value": "1"
    },
    {
      "name": "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS",
      "value": "1"
    }
  ],

  // 2. 指定当前选中的主力模型
  "claudeCode.selectedModel": "deepseek-v4-pro",

  // 3. 禁用登录提示
  "claudeCode.disableLoginPrompt": true
}
```
## 使用
### Slash Command
``` 
模型与成本监控
/model 查看当前生效的模型
/model <sonnet|opus> 切换模型
/usage token消耗

上下文与会话管理
/compact 压缩上下文
/clear 硬重置
/context 查看
```
