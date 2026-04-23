# Troubleshooting

只在正常路径失败后再读这个文件。默认先按 `SKILL.md` 里的 step-by-step workflow 执行。

## First Split The Failure

- 配置 / 加载失败：先当成配置目录、provider 定义、schema 路径或 auth 解析问题
- 模型 / capability 不匹配：先当成 model 不存在，或 model 不支持目标 operation
- 参数校验失败：先当成 `--args-file`、`--args`、`--arg`、显式 flags 合并后仍不满足 schema
- provider 执行 / 网络 / 鉴权失败：先当成 endpoint、网络、代理、密钥或上游 provider 返回异常
- 输出 / 存储失败：先当成输出目录、文件命名、写权限或 manifest 写回问题
- 导入失败：先当成 `--item` 结构、URL / data URL / base64 / data_path 输入不合法
- `verify` 失败：先当成真实请求验证失败，不要把它当成 discovery 命令

## Default Diagnostic Order

排障时默认顺序：

1. `imagine providers`
2. `imagine models`
3. `imagine model <model>`
4. `imagine inspect <tool>`
5. `imagine generate` / `imagine edit` / `imagine import`
6. `imagine config validate`
7. `imagine verify`

不要默认先读：

- `~/.config/imagine`
- `examples/*.toml`
- schema JSON
- `internal/` 源码

如果内置子命令已经足够回答问题，就不要再去翻文件。

如果怀疑当前运行环境用的不是预期配置目录，先把命令切成带 `--config <dir>` 的形式再看结果。

## When To Use `inspect`

`imagine inspect <tool>` 只编译和展示工具调用，不执行真实请求。适合在下面几种情况使用：

- 不确定最终 args 是否合并正确
- 不确定 `model`、`prompt`、`image`、`response_format`、`output_name` 是否落到了最终请求
- 不确定 `--args-file`、`--args`、`--arg`、显式 flags 的覆盖顺序是否符合预期
- 请求失败后，需要确认最终编译结果

常见形态：

```bash
imagine inspect image.generate --args '{"model":"gemini-2.5-flash-image","prompt":"otter"}'
imagine inspect image.edit --args '{"model":"gemini-2.5-flash-image-edit","prompt":"poster","image":"./seed.png"}'
imagine inspect image.import --args '{"item":{"type":"url","value":"https://example.com/image.png"}}'
```

不要把 `inspect` 变成每次都跑的默认第一步，也不要用它替代真实执行。

## Config / Load Failures

优先检查：

- `imagine providers` 是否能正常列出 provider
- `imagine models` 是否能正常列出 model
- `imagine model <model>` 是否能返回模型摘要
- `imagine config validate` 是否能成功通过
- 是否误用了错误的配置目录
- 是否需要显式补 `--config ./examples` 或其他 config dir

只有当 discovery 命令和 `config validate` 仍不足以解释问题时，才允许少量读取对应 TOML 或 schema 文件作为最后兜底。不要把扫配置目录当成默认流程。

## Model / Capability Mismatch

优先检查：

- 目标 model 是否存在于 `imagine models`
- 是否把 model 名和 tool 名混用了
- `imagine model <model>` 是否显示支持目标 operation
- 是否本来应该走 `generate` 却跑了 `edit`
- 是否本来应该走 `edit` 却没有提供 `--image`

如果 `model <model>` 已经说明 capability 不匹配，不要继续猜 schema 或源码。

## Argument Validation Problems

优先检查：

- `--args-file` 是否是 JSON object
- `--args` 是否是 JSON object
- `--arg key=json` 的值是否是合法 JSON
- 显式 flags 是否覆盖了前面的 JSON 输入
- `model`、`prompt`、`image` 等必填字段是否真的传入
- `imagine inspect <tool>` 的结果是否和预期一致

先用输入和 `inspect` 定位问题，不要手工下钻 raw file 内容。

## Provider Execution / Network / Auth Failures

优先检查：

- `imagine inspect <tool>` 的最终请求是否符合预期
- 配置目录是否指向了正确 provider 配置
- 网络、代理、endpoint 是否可达
- provider 密钥是否存在且可用
- 失败是否只在真实执行时出现，而不是 discovery / inspect 阶段

只有当用户明确要求真实连通性验证，或你已经确认 `inspect` 仍不足以解释问题时，才执行：

```bash
imagine verify
```

必要时补：

```bash
imagine --config ./examples verify
```

`verify` 会发真实请求，可能消耗额度，也可能因为网络和上游 provider 抖动而失败。

## Output / Storage Failures

优先检查：

- 是否指定了正确的 `--output-dir`
- 输出目录是否存在且可写
- `--output-name` 是否合理
- 最终文件是否成功落盘
- `.imagine-assets.json` 是否只是附带更新失败，还是主输出本身也失败

不要把 manifest 当成主要接口。先确认最终图片文件是否成功生成或导入。

## Import Failures

优先检查：

- `--item` 是否是合法 JSON object
- `type` 是否是当前支持的输入类型：
  - `url`
  - `data_url`
  - `base64`
  - `data_path`
- URL / data URL / base64 内容是否本身可解析
- `data_path` 是否指向允许读取的位置

默认优先修正 `--item` 输入，不要先去查内部实现。

## `verify` Failures

优先检查：

- 这是不是用户真正想要的动作
- 当前 config dir 是否正确
- 目标 provider 是否需要真实可用密钥
- 网络、代理、配额和上游 provider 状态是否正常

如果只是想确认有哪些 provider、model，或某个模型支持什么能力，就退回 `providers`、`models`、`model`，不要继续把 `verify` 当 discovery 命令用。

## Security Notes

- provider 密钥是高敏感信息
- 不要在排障时默认展开或转述真实密钥
- `verify` 和真实执行都会触发外部请求
- raw config / schema 不是默认排障接口
- 如果必须读取配置文件兜底，控制在最小范围内，不要顺手扩大到整个目录
