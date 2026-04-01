# viewport-servers

## 1. 目录简介

这个目录保存 viewport server 的模板配置，用来描述可被前端或界面层消费的 viewport 服务端点。

## 2. 如何制作一个 Viewport Server 配置

新增一个 viewport server 时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定稳定的 `serverKey`。
2. 填写服务地址 `baseUrl`。
3. 填写 viewport 端点路径 `endpointPath`。
4. 保存为与 `serverKey` 尽量一致的文件名，便于排查和同步。

可参考的最小骨架：

```yaml
serverKey: your-server-key
baseUrl: http://your-viewport-server:8080
endpointPath: "/mcp"
```

## 3. 常见字段

- `serverKey`：服务的稳定标识，建议与文件名保持一致。
- `baseUrl`：viewport server 的基础地址。
- `endpointPath`：服务端点路径。

这里维护的是模板结构，不负责保存运行时状态。

## 4. 编写约定

- 一个文件只描述一个 viewport server。
- 文件名尽量与 `serverKey` 一致，便于查找与同步。
- 如果某个服务同时暴露 MCP 与 viewport 能力，应分别在对应目录维护配置。
- 配置事实以 YAML 为准，README 只负责说明如何编写。

## 5. 提交边界

- 可提交：模板化端点定义与通用说明。
- 不提交：环境专属的私有地址、凭据或临时联调配置。
