# Troubleshooting

只在正常路径失败后再读这个文件。默认先按 `SKILL.md` 里的 step-by-step workflow 执行。

## First Split The Failure

- `401` / `403`：先当成 HTTP 认证症状，优先怀疑登录态、cookie 或 state 目录
- `config_error`：先当成 site 不存在、action 不存在、配置不合法或编译失败
- `state_error`：先当成 state 路径、权限、文件缺失或损坏问题
- `execution_error`：先当成动态值缺失、请求发送失败或写回 state 失败
- `assertion_error`：先当成 `expect_status`、`extract_*`、`save` 与真实响应不匹配

## Default Diagnostic Order

排障时默认顺序：

1. `httpx site <site>`
2. `httpx actions <site>`
3. `httpx action <site> <action>`
4. `httpx state <site>`
5. `httpx inspect <site> <action>`
6. `httpx login <site>` 或 `httpx run <site> <action>`

不要默认先读：

- `~/.config/httpx/*.toml`
- `~/.local/httpx-state/*.json`
- 用户口中的 `conf`
- 用户口中的 `local`

如果内置子命令已经足够回答问题，就不要再去翻文件。

如果怀疑当前运行环境用的不是预期 state 目录，先把命令切成带 `--state <dir>` 的形式再看结果。

## Fast Path For `401` / `403`

不要在这个阶段横向试很多 action。优先缩小为认证问题。

1. 先确认目标 action 是否本来就依赖登录态
2. 先看 `httpx state <site>`，确认 state 是否存在、`last_login` 是否为空，以及是否有已保存值或 cookie 摘要
3. 如果怀疑 state 目录不对，改用 `httpx --state <dir> state <site>` 复查
4. 如果 site 定义了 `login_action`，执行 `httpx --state <dir> login <site>` 或 `httpx login <site>`
5. 再重试 `httpx --state <dir> run <site> <action>` 或 `httpx run <site> <action>`
6. 只有仍然失败时，才用 `httpx inspect <site> <action>` 看最终编译结果

如果 `httpx login <site>` 报没有 `login_action`，这是配置能力边界，不是 cookie 过期。

## When To Use `inspect`

`httpx inspect <site> <action>` 只编译请求，不发请求。适合在下面几种情况使用：

- 不确定最终 URL、method、query、headers、cookies 是否合并正确
- 不确定 `param`、`extract`、`env`、`file`、`shell`、`state` 是否被正确解析
- 不确定 `proxy` 配置是否正确
- 请求失败后，需要确认最终编译结果

必要时带上运行时输入：

```bash
httpx inspect <site> <action> --param key=value
httpx inspect <site> <action> --extract '{"key":"value"}'
```

默认会脱敏敏感值。只有脱敏遮住关键信息时，才加 `--reveal`。

不要把 `inspect` 变成每次都跑的默认第一步，也不要给它配不支持的格式。

## `config_error`

优先检查：

- `httpx site <site>` 是否能正常返回 site 摘要
- `httpx actions <site>` 是否能列出目标 action
- `httpx action <site> <action>` 是否展示预期调用方式和输入契约
- `httpx inspect <site> <action>` 是否能成功编译
- `login_action` 是否存在且指向真实 action
- action 是否同时配置了 `body` 和 `form`
- dynamic source 的 `from` 和字段是否有效
- extractor 是否使用当前支持的扁平字段：
  - `extract_type`
  - `extract_expr`
  - `extract_pattern`
  - `extract_group`
  - `extract_all`

只有当 discovery 命令和 `inspect` 仍不足以解释问题时，才允许少量读取对应 config 文件作为最后兜底。不要把扫 config 目录当成默认流程。

## `state_error`

优先检查：

- `httpx state <site>` 的输出
- state 路径是否存在、是否可读写
- 是否误把短生命周期目录当成 state 目录
- 是否在容器、沙箱或临时目录里丢失了运行时状态
- 必要时显式用 `httpx --state <dir> state <site>`、`httpx --state <dir> login <site>`、`httpx --state <dir> run <site> <action>` 验证问题是否只是目录选错

不要默认直接读取原始 state JSON。state 是本地运行时状态，不是稳定公共接口；除非用户明确要求，否则不查看 `~/.local/httpx-state/*.json` 内容。

## `execution_error`

优先检查：

- `--param` 是否传入，或配置了默认值
- `--extract` 是否传入了 action 需要的运行时输入
- `env` 对应环境变量是否存在
- `state` source 对应 key 是否存在
- `file` 路径是否可读
- `shell` 命令是否失败或超时
- 网络请求本身是否失败
- `httpx inspect <site> <action>` 的编译结果是否符合预期

先用命令输入和 `inspect` 定位问题，不要手工下钻 raw file 内容。

## `assertion_error`

优先检查：

- 返回状态码是否符合 `expect_status`
- `extract_*` 是否匹配实际响应
- `save` 表达式是否能产出可保存值
- `httpx inspect <site> <action>` 中的最终请求是否和预期一致

## Security Notes

- state 文件中的 token 和 cookie 是明文保存
- `inspect` 默认脱敏，但 `--reveal` 会显示真实值
- raw state 内容不是默认排障接口
- 如果必须读取配置文件兜底，控制在最小范围内，不要顺手扩大到 `.local` 内容
