# Models Registry

`models/*.yml` 定义模型元数据；当同一个 provider 下不同模型的 OpenAI 兼容行为不一致时，优先把 compat 写在 model 上。

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

OpenAI 兼容扩展字段：

```yaml
compat:
  request:
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

适用场景：

- 综合性 API 网关，例如 `babelark`
- 同一个 provider 下只有个别模型会返回 `<think>` 或 `reasoning_details`
- 需要覆盖 provider 级默认 compat

优先级：

- 运行时会先读取 provider 级 compat
- 再叠加 model 级 compat
- model 级优先级更高
- `request.whenReasoningEnabled` 里的 `null` 会移除继承自 provider 的同名字段

当前建议：

- `minimax` 官网原厂兼容配置放在 provider 级
- `babelark-minimax-m2_7` 这类网关特例放在 model 级
