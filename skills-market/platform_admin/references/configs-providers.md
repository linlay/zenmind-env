# Configs: Providers

当前工作区 provider 配置位于 `/providers/<provider-key>.yml`，宿主机运行时目录通常映射到 `.zenmind/registries/providers/<provider-key>.yml`；示例模板源位于 `.zenmind/registries.example/providers/<provider-key>.yml`。

## Loader 契约

- `key`
- `baseUrl`
- `defaultModel`
- `protocols.<PROTOCOL>.endpointPath`

`key` 与 `baseUrl` 应优先保持在头部；`defaultModel` 与 `protocols` 是当前 runner 支持的 provider schema 组成部分。

## 常见字段

- `apiKey`

## 敏感性规则

- `apiKey` 属于敏感信息
- 默认不要在最终回答里回显完整值
- 如需确认是否存在，可说“已检测到 apiKey”或只显示掩码形式
- 修改时尽量定点替换，不要把整份 provider 文件完整抄回回答

## 修改原则

- `key` 应与文件名语义一致
- `defaultModel` 变更前，确认对应模型存在于 `/models`（宿主机运行时通常对应 `.zenmind/registries/models`；示例模板源对应 `.zenmind/registries.example/models`）
- `baseUrl` 变更时，尽量保持协议、主机和路径清晰，不顺手改动无关字段
- 历史字段 `model` 已不再支持；需要默认模型时使用 `defaultModel`
- 若使用 `protocols`，只补对应协议下的 `endpointPath`，不要顺手改动其他协议段
- 保留未知字段，不要因为模板中没提到就删除

## 参考模板

```yaml
key: providerKey
baseUrl: https://example.com/compatible-mode
apiKey: <redacted>
defaultModel: some-model
protocols:
  OPENAI:
    endpointPath: /chat/completions
```

## 推荐检查顺序

1. `ls /providers`
2. `sed -n '1,40p' /providers/<provider-key>.yml`
3. 修改前读全文，但最终回复避免泄露 secret
4. 写后回读非敏感字段，敏感字段只确认存在或已更新
