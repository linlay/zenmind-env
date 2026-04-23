# Registries: MCP Servers

当前工作区 MCP server 注册配置位于 `/mcp-servers/<server-key>.yml`，宿主机运行时目录通常映射到 `.zenmind/registries/mcp-servers/<server-key>.yml`；示例模板源位于 `.zenmind/registries.example/mcp-servers/<server-key>.yml`。

## Loader 契约

- `serverKey`
- `baseUrl`
- `endpointPath`

这 3 个字段是当前 remote server loader 的核心契约，应优先保持在头部。

## 可选运行字段

- `enabled`
- `toolPrefix`
- `headers`
- `connectTimeoutMs`
- `readTimeoutMs`
- `retry`
- `aliasMap`

## 修改原则

- `serverKey` 应与文件名语义一致
- `baseUrl` 与 `endpointPath` 一起看，避免把完整 URL 与 path 重复拼接
- `enabled` 改动会影响可用性，修改前先确认是否为预期
- `aliasMap` 是工具别名映射；增删时不要破坏既有键值对格式
- 不要把 `name`、`transport` 当作这个运行目录下的必需字段；当前 loader 以 `serverKey`、`baseUrl`、`endpointPath` 为准

## 审查重点

- URL 是否是预期协议与端口
- `endpointPath` 是否以 `/` 开头
- `aliasMap` 是否仍然指向明确工具名
- 是否有无意义的重复别名
- timeout 与 retry 是否只在用户要求时定点调整

## 推荐检查顺序

1. `ls /mcp-servers`
2. `sed -n '1,80p' /mcp-servers/<server-key>.yml`
3. 修改前读全文
4. 写后回读头部与 `aliasMap`
