# Configs: Models

当前工作区模型配置位于 `/models/<model-key>.yml`，宿主机运行时目录通常映射到 `.zenmind/registries/models/<model-key>.yml`；示例模板源位于 `.zenmind/registries.example/models/<model-key>.yml`。

## Loader 契约

- `key`
- `provider`
- `protocol`
- `modelId`

这 4 个字段应优先保持在头部，runner 会按 `key`、`provider`、`protocol`、`modelId` 校验模型文件头部与核心定义。

## 常见扩展字段

- `isReasoner`
- `isFunction`
- `maxTokens`
- `maxInputTokens`
- `maxOutputTokens`
- `pricing`

## 当前工作区样式

- 文件名通常与 `key` 一致
- `pricing` 下可能包含：
  - `promptPointsPer1k`
  - `completionPointsPer1k`
  - `perCallPoints`
  - `priceRatio`
  - `tiers`

## 修改原则

- 改模型别名或绑定关系时，优先保持 `key` 稳定，除非用户明确要求重命名
- 改 token 上限时，同时检查 `maxTokens`、`maxInputTokens`、`maxOutputTokens` 是否仍然自洽
- 改 `provider` 时，确认目标 provider 在 `/providers` 中存在（宿主机运行时通常对应 `.zenmind/registries/providers`；示例模板源对应 `.zenmind/registries.example/providers`）
- 改 `protocol` 时，不要随意发明新枚举值
- 若 `provider` 不存在，或 `protocol` 不受支持，runner 会跳过该模型文件

## 推荐检查顺序

1. `ls /models`
2. `sed -n '1,80p' /models/<model-key>.yml`
3. 修改前读全文
4. 写后回读头部与 `pricing` 段
