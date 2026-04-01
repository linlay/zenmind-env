# Providers Registry

`providers/*.yml` 定义 provider 级配置，适合整条上游 OpenAI 兼容链路都表现一致的场景。

常规字段：

- `key`
- `baseUrl`
- `apiKey`
- `defaultModel`
- `protocols.<PROTOCOL>.endpointPath`

OpenAI 兼容扩展字段：

```yaml
protocols:
  OPENAI:
    compat:
      request:
        whenReasoningEnabled:
          reasoning_split: true
      response:
        reasoningFormats:
          - REASONING_DETAILS_TEXT
          - REASONING_CONTENT
          - THINK_TAG_CONTENT
        thinkTag:
          start: "<think>"
          end: "</think>"
          stripFromContent: true
```

适用场景：

- 官网原厂 provider，例如 `minimax`
- 同一个 provider 下大多数模型返回格式一致

说明：

- `request.whenReasoningEnabled` 只会在 agent/llm 已开启 reasoning 时附加到请求体
- 不允许覆盖内建字段：`model`、`stream`、`messages`、`reasoning`、`tools` 等
- `response.reasoningFormats` 用来声明上游会怎样返回 reasoning
- `THINK_TAG_CONTENT` 表示 reasoning 在 `content` 里的 `<think>...</think>` 片段中

如果某个网关 provider 下不同模型行为不同，不要写在 provider 上，改写到对应的 `models/*.yml`。
