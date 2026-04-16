# Models Registry

`models/*.yml` 定义模型元数据；同一底层模型若同时支持 OPENAI / ANTHROPIC，建议拆成不同 `modelKey`。当同一个 provider 下不同模型的协议兼容行为不一致时，优先把 compat 写在 model 上。

常规字段：

- `key`
- `provider`
- `protocol`
- `modelId`
- `isReasoner`
- `isFunction`
- `maxTokens`
- `maxInputTokens`
- `maxOutputTokens`
- `pricing`
- `headers`（可选）
- `compat`（可选）

OpenAI 兼容扩展字段：

```yaml
compat:
  request:
    always: {}
    whenReasoningEnabled: {}
  response:
    reasoningFormats:
      - REASONING_CONTENT
      - THINK_TAG_CONTENT
    thinkTag:
      start: "<think>"
      end: "</think>"
      stripFromContent: true
```

Anthropic 兼容扩展字段：

```yaml
headers:
  anthropic-beta: tools-2024-04-04
compat:
  request:
    whenReasoningEnabled:
      thinking:
        budget_tokens: 4096
```

适用场景：

- 综合性 API 网关，例如 `babelark`
- 同一个 provider 下只有个别模型会返回 `<think>` 或 `reasoning_details`
- 需要覆盖 provider 级默认 compat

优先级：

- 运行时会先读取 provider 级 compat
- 再叠加 model 级 compat
- model 级优先级更高
- `request.always` 会无条件附加到请求体，适合 `reasoning_split` 这类返回格式开关
- `request.whenReasoningEnabled` 里的 `null` 会移除继承自 provider 的同名字段

当前建议：

- `minimax` 官网原厂兼容配置放在 provider 级；`reasoning_split` 这类返回格式开关优先放 `request.always`
- `babelark-minimax-m2_7` 这类网关特例放在 model 级
