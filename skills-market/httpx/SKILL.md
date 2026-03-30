---
name: "httpx"
description: "Use this skill when the user wants to use or troubleshoot httpx sites and actions through the built-in subcommands, discover available sites/actions/state summaries, inspect compiled requests, run login/run flows, or diagnose errors without treating raw config/state files as the primary interface."
---

# httpx

先读这个 skill，再操作 `httpx`。

把 `httpx` 当成面向 site/action 工作流的 CLI，不要把它当成 `curl` 兼容命令去猜参数，也不要把 `conf`、`local`、原始 config/state 文件当成默认入口。

正常路径只走内置子命令。只有当内置子命令已经不能解释问题时，才允许把读取原始文件当成最后兜底排障。

## Core Rules

- 先 discovery，后 execution
- 先 `action <site> <action>` 看输入契约，再决定怎么跑 `run`
- 不要默认读取：
  - `~/.config/httpx/*.toml`
  - `~/.local/httpx-state/*.json`
- 不要默认去看用户口中的 `conf` 或 `local`
- 需要切换运行环境时，优先补 `--config <dir>` 或 `--state <dir>` 重试内置命令
- 只有排障时，才允许少量、定点读取具体 raw file

## Default Model

- discovery 子命令：
  - `httpx sites`
  - `httpx site <site>`
  - `httpx actions <site>`
  - `httpx action <site> <action>`
  - `httpx state <site>`
- execution 子命令：
  - `httpx inspect <site> <action>`
  - `httpx login <site>`
  - `httpx run <site> <action>`
- `action <site> <action>` 是执行前的标准步骤：
  - 它会展示调用方式
  - 它会展示 `--param` 和 `--extract` 输入契约
  - 它会展示示例命令
- `login <site>` 是独立子命令，不是普通 action 名
- `login <site>` 会执行 site 配置里的 `login_action`
- 如果 site 没有配置 `login_action`，`login <site>` 失败是正常行为
- `state <site>` 只展示摘要：
  - 是否存在 state
  - state 文件路径
  - `last_login`
  - 已保存值数量
  - cookie 数量
- 默认输出格式：
  - `run` / `login` 默认 `text`
  - `inspect` 默认 `json`
  - `sites` / `site` / `actions` / `action` / `state` 默认 `text`
- `inspect` 只支持 `json`
- `run` / `login` 支持 `text` 或 `json`
- discovery 命令支持 `text` 或 `json`
- `--state <dir>` 覆盖的是 state 目录，不是单个 state 文件
- `--reveal` 只在 `inspect` 下有效
- `--extract` 不支持 `login` 和 discovery 命令
- `--timeout` 不支持 discovery 命令
- 未显式配置 `proxy` 时默认直连，不继承环境代理

## Default Workflow

默认必须按这个顺序执行，不要跳步：

1. 先读这个 skill，确认不要先看 `conf`、`local` 或 raw file
2. 执行 `httpx sites`
3. 执行 `httpx site <site>`
4. 执行 `httpx actions <site>`
5. 执行 `httpx action <site> <action>`
6. 执行 `httpx state <site>`
7. 根据 `site`、`action`、`state` 输出判断这个 action 是否依赖登录态
8. 只有当请求形状、动态值、代理或最终编译结果可疑时，才执行 `httpx inspect <site> <action>`
9. 只有 action 明显依赖登录态，或用户明确要求登录时，才执行 `httpx login <site>`
10. 最后执行 `httpx run <site> <action>`

不要一上来就跑 `inspect`，也不要一上来就读本地文件内容。

如果怀疑问题出在 state 目录选错、容器挂载不对、运行环境不对，优先补 `--state <dir>` 重跑 `site`、`state`、`login`、`run`，不要先去翻 raw state 文件。

## Step-By-Step Command Use

### Step 1: Find The Site

先用：

```bash
httpx sites
```

目标：

- 确认有哪些 site
- 确认目标 site 名称是否真实存在
- 粗看每个 site 是否已有 state

### Step 2: Read The Site Summary

再用：

```bash
httpx site <site>
```

重点看：

- `description`
- `base_url`
- `login_action`
- action 数量
- state 摘要

这一步只看摘要，不看 raw config。

### Step 3: List Actions

再用：

```bash
httpx actions <site>
```

目标：

- 确认目标 action 是否存在
- 先看 action 名和描述
- 缩小后续要检查的 action

### Step 4: Inspect The Action Contract

执行前必须用：

```bash
httpx action <site> <action>
```

这一步是默认执行前置检查。重点看：

- `Usage`
- `Flags`
- `Params fields`
- `Extracts fields`
- `Examples`

如果 action 需要 `--param` 或支持 `--extract`，优先以这里显示的输入契约和示例为准，不要自己猜。

### Step 5: Check State Summary

再用：

```bash
httpx state <site>
```

目标：

- 判断 state 是否存在
- 判断最近是否登录过
- 判断是否保存过 cookie 或运行时值

默认只看摘要，不读取原始 state JSON。

### Step 6: Decide Whether Login Is Needed

只有下面情况才考虑登录：

- `site <site>` 显示存在 `login_action`
- 目标 action 明显依赖 cookie、token 或保存值
- `state <site>` 显示没有可用 state
- 用户明确要求先登录

如果 site 没有 `login_action`，不要机械地先跑 `login`。

### Step 7: Use `inspect` Only When Needed

只有下面场景才跑：

- 不确定最终 URL、method、query、headers、cookies 是否正确
- 不确定 `param`、`extract`、`env`、`file`、`shell`、`state` 是否解析正确
- 怀疑 `proxy` 配置有问题
- `run` 失败后，需要确认最终编译结果

常见形态：

```bash
httpx inspect <site> <action>
httpx inspect <site> <action> --param key=value
httpx inspect <site> <action> --extract '{"group":"WRM"}'
```

默认脱敏。只有脱敏遮住关键诊断信息时，才加 `--reveal`。

### Step 8: Run Login When Needed

需要登录时再跑：

```bash
httpx login <site>
```

如果是环境或目录问题，优先改成：

```bash
httpx --state <dir> login <site>
```

### Step 9: Run The Target Action

最后再跑：

```bash
httpx run <site> <action>
```

如果 `action <site> <action>` 显示需要运行时输入，再补对应参数：

```bash
httpx run <site> <action> --param key=value
httpx run <site> <action> --extract '{"key":"value"}'
```

默认优先使用 `text` 输出；只有用户明确需要结构化输出时，才切到 `--format json`。

## Discovery First

优先用 discovery 子命令回答这些问题：

- 有哪些 site：`httpx sites`
- 某个 site 的基本信息是什么：`httpx site <site>`
- 某个 site 有哪些 action：`httpx actions <site>`
- 某个 action 需要什么输入、怎么调用：`httpx action <site> <action>`
- 某个 site 是否存在本地 state：`httpx state <site>`

这些命令是默认信息入口，不推荐先去读：

- `~/.config/httpx/*.toml`
- `~/.local/httpx-state/*.json`

## File Reading Policy

- 正常使用时，不读取 `~/.config/httpx/*.toml`
- 正常使用时，不读取 `~/.local/httpx-state/*.json`
- 正常使用时，不去看用户口中的 `conf`、`local` 原始内容
- 优先使用 `site`、`actions`、`action`、`state`、`inspect` 获取信息
- 需要切换配置目录时，优先使用 `--config <dir>`
- 需要切换 state 目录时，优先使用 `--state <dir>`
- 只有当内置子命令已经不足以解释问题时，才允许读取具体 config 文件作为最后兜底
- 只有当用户明确要求，或排障已经被原始 state 内容阻塞时，才允许读取具体 state 文件
- 即使进入兜底排障，也只做针对性的少量读取，不把扫目录当成默认流程

## Canonical Commands

常用命令形态：

```bash
httpx sites
httpx site <site>
httpx actions <site>
httpx action <site> <action>
httpx state <site>
httpx inspect <site> <action>
httpx login <site>
httpx run <site> <action>
```

常用带目录覆盖的形态：

```bash
httpx --config <dir> sites
httpx --config <dir> site <site>
httpx --config <dir> actions <site>
httpx --config <dir> action <site> <action>
httpx --config <dir> state <site>
httpx --config <dir> inspect <site> <action>
httpx --config <dir> login <site>
httpx --config <dir> run <site> <action>
httpx --config <dir> --state <state-dir> state <site>
httpx --config <dir> --state <state-dir> login <site>
httpx --config <dir> --state <state-dir> run <site> <action>
```

也可以把全局参数放在子命令后：

```bash
httpx run <site> <action> --format json --config <dir>
httpx inspect <site> <action> --config <dir>
httpx action <site> <action> --format json --config <dir>
httpx state <site> --format json --config <dir>
```

约束提醒：

- `inspect` 只支持 `--format json`
- `run` / `login` 支持 `text` 或 `json`
- `sites` / `site` / `actions` / `action` / `state` 只支持 `text` 或 `json`
- `--extract` 不支持 `login` 和 discovery 命令
- `--timeout` 不支持 discovery 命令
- `--state` 覆盖的是 state 目录
- `--reveal` 只支持 `inspect`
- `login` 只适用于配置了 `login_action` 的 site

## Config Model Facts

- site 必要字段：
  - `version = 1`
  - `description`
  - `base_url`
  - `actions`
- action 必要字段：
  - `description`
  - `path`
- 常见 site 顶层字段：
  - `login_action`
  - `proxy`
  - `timeout`
  - `retries`
  - `headers`
  - `cookies`
  - `query`
- 常见 action 字段：
  - `method`
  - `path`
  - `proxy`
  - `timeout`
  - `retries`
  - `headers`
  - `cookies`
  - `query`
  - `body`
  - `form`
  - `expect_status`
  - `extract_type`
  - `extract_expr`
  - `extract_pattern`
  - `extract_group`
  - `extract_all`
  - `params`
  - `extracts`
  - `save`
- 同一个 action 不能同时设置 `body` 和 `form`
- 没写 `method` 时：
  - 有 `body` 或 `form` 默认 `POST`
  - 否则默认 `GET`

## Dynamic Values And Runtime Input

- 动态值来源：
  - `literal`
  - `param`
  - `env`
  - `file`
  - `shell`
  - `state`
- 运行时输入契约分成两类：
  - `params = [...]` 对应 `--param key=value`
  - `extracts = [...]` 对应 `--extract <json-object>`
- 默认先看 `httpx action <site> <action>` 给出的输入契约，不要自己猜
- state 保存三类运行时数据：
  - cookie
  - `save` 提取出的值
  - `last_login`
- state 是本地运行时状态，不是稳定外部 API
- 需要确认 state 是否存在时，先用 `httpx state <site>`
- 需要切换 state 目录时，先用 `httpx --state <dir> state <site>`

## Failure Routing

- `401` / `403`：
  - 先把它当成 HTTP 症状，不是 CLI 错误码
  - 先看 `httpx state <site>`
  - 如果怀疑 state 目录不对，改用 `httpx --state <dir> state <site>`
  - 需要时执行 `httpx login <site>`
  - 再重试 `httpx run <site> <action>`
  - 只有仍然不清楚时，才执行 `httpx inspect <site> <action>`
- `config_error`：
  - 先跑 `httpx site <site>`
  - 再跑 `httpx actions <site>`
  - 再跑 `httpx action <site> <action>`
  - 必要时跑 `httpx inspect <site> <action>`
  - 只有这些都不足以解释问题时，才少量读取 config 文件
- `state_error`：
  - 先检查 `httpx state <site>` 的输出
  - 再检查 state 路径、目录和权限
  - 必要时显式补 `--state <dir>` 重试
  - 不要默认去读原始 state 内容
- `execution_error`：
  - 先检查 `param`、`env`、`file`、`shell`、`state` 等动态值是否可用
  - 再用 `httpx inspect <site> <action>` 看最终编译结果
- `assertion_error`：
  - 先检查 `expect_status`
  - 再检查 `extract_*`
  - 再检查 `save`
  - 再结合 `inspect` 结果判断请求是否打偏

## References

只在正常路径失败或行为明显不符合预期时再读：

- `references/troubleshooting.md`
