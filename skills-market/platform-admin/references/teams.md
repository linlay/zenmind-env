# Teams

team 文件在容器内位于 `/teams/<team-id>.yml`。

## 文件与命名契约

- `team-id` 取文件名，不取 YAML 内字段
- `team-id` 应为 12 位十六进制小写字符串
- 头部优先保持：
  - 第 1 行 `name: ...`
  - 第 2 行 `defaultAgentKey: ...`

## 常见字段

- `name`: team 名称
- `defaultAgentKey`: 默认 agent
- `agentKeys`: 该 team 可用 agent 列表

## 一致性检查

- `defaultAgentKey` 应该出现在 `agentKeys` 中
- `agentKeys` 不应重复
- `agentKeys` 中的 agent 应该真实存在于 `/agents`
- 修改 team 前先看目标 agent 是否存在，避免写入无效 key

## 最小模板

```yaml
name: Default Team
defaultAgentKey: someAgent
agentKeys:
- someAgent
- anotherAgent
```

## 推荐检查顺序

1. `ls /teams`
2. `sed -n '1,40p' /teams/<team-id>.yml`
3. 如需修改，再读取全文
4. 写后回读全文并核对 `defaultAgentKey` 与 `agentKeys`
