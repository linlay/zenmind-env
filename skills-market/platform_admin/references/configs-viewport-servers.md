# Configs: Viewport Servers

当前工作区 viewport server 配置位于 `/viewport-servers/<server-key>.yml`，宿主机运行时目录通常映射到 `.zenmind/registries/viewport-servers/<server-key>.yml`；示例模板源位于 `.zenmind/registries.example/viewport-servers/<server-key>.yml`。

## Loader 契约

- `serverKey`
- `baseUrl`
- `endpointPath`

这 3 个字段是当前 remote server loader 的核心契约，应优先保持在头部。

## 可选运行字段

- `headers`
- `connectTimeoutMs`
- `readTimeoutMs`
- `retry`

有些定义也可能带 `name`、`transport` 或其他扩展字段；若目标文件已有这些字段，应保留并做定点修改，但不要把它们当成运行时必需字段。

## 修改原则

- 先以目标文件现状为准，不强行套用别的模板
- `serverKey` 应与文件名语义一致
- `baseUrl` 改动时，不顺手改掉无关路径
- `endpointPath` 保持以 `/` 开头
- 不要把 `name`、`transport` 当作这个运行目录下的必填契约
- 若新增字段，优先沿用同目录现有文件风格

## 审查重点

- 是否能明确区分 `baseUrl` 和 `endpointPath`
- 是否保留现有非标准字段
- 是否只修改用户要求的 server
- timeout / retry / headers 是否与目标服务接入需求一致

## 推荐检查顺序

1. `ls /viewport-servers`
2. `sed -n '1,60p' /viewport-servers/<server-key>.yml`
3. 修改前读全文
4. 写后回读头部与关键连接字段
