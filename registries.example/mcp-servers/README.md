# mcp-servers

## 1. 目录简介

这个目录保存 MCP server 的模板配置。每个 `*.yml` 对应一个可连接的 MCP 服务实例定义，供工作区初始化和打包使用。

## 2. 如何制作一个 MCP Server 配置

新增一个 MCP server 时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定稳定的 `serverKey`。
2. 再填写服务地址 `baseUrl` 和接口路径 `endpointPath`。
3. 如果该服务默认启用，写上 `enabled: true`；否则显式关闭。
4. 只有在需要给工具名加前缀时，才配置 `toolPrefix`。
5. 如果上游服务响应较慢，再按需补 `readTimeoutMs`。

可参考的最小骨架：

```yaml
serverKey: your-server-key
baseUrl: http://your-mcp-server:8080
endpointPath: "/mcp"
enabled: true
```

## 3. 常见字段

- `serverKey`：服务的稳定标识，建议与文件名保持一致。
- `baseUrl`：MCP server 的基础地址。
- `endpointPath`：MCP 协议端点路径，常见值是 `"/mcp"`。
- `enabled`：是否启用该服务。
- `toolPrefix`：可选。需要避免工具名冲突时使用。
- `readTimeoutMs`：可选。用于声明读取超时。

配置事实以各个 YAML 为准，README 不维护默认值。

## 4. 编写约定

- 一个文件只描述一个 MCP server。
- 文件名尽量与 `serverKey` 一致，便于排查和同步。
- 如果某项能力属于运行时启停或环境差异，请写入具体 YAML，不要只写在文档里。
- 如果配置差异属于 model/provider 范畴，应分别放到对应目录，不要混写在这里。

## 5. 提交边界

- 可提交：通用模板、示例连接参数、与环境无关的结构说明。
- 不提交：只在本地环境可用的私有地址、真实密钥或临时调试变体。
