---
name: "imagine"
description: "Use this skill when the user wants to use or troubleshoot the imagine CLI for provider/model discovery, inspect compiled tool calls, generate or edit images, import external images, validate configuration, or diagnose failures without treating raw config/schema files as the primary interface."
---

# imagine

先读这个 skill，再操作 `imagine`。

把 `imagine` 当成配置驱动的本地图像 CLI，不要把它当成原始 HTTP 调试器，也不要把 `~/.config/imagine`、`examples/*.toml`、schema JSON 或内部源码当成默认入口。

正常路径只走内置子命令。只有当内置子命令已经不能解释问题时，才允许把读取原始配置文件当成最后兜底排障。

## Core Rules

- 先 discovery，后 execution
- 先 `model <model>` 看模型能力，再决定走 `generate`、`edit` 还是 `run`
- 正常使用时，不要默认读取：
  - `~/.config/imagine`
  - repo 里的 `examples/*.toml`
  - repo 里的 schema JSON
  - `internal/` 下源码
- 需要切换运行环境时，优先补 `--config <dir>` 重试内置命令
- 只有排障时，才允许少量、定点读取具体 raw file

## Default Model

- discovery 子命令：
  - `imagine providers`
  - `imagine models`
  - `imagine model <model>`
- execution 子命令：
  - `imagine generate`
  - `imagine edit`
  - `imagine import`
  - `imagine inspect <tool>`
  - `imagine run <tool>`
  - `imagine config validate`
  - `imagine verify`
- `providers`、`models`、`model` 是默认信息入口
- `generate`、`edit`、`import` 是默认执行入口
- `run <tool>` 只在下面情况优先使用：
  - 用户已经有完整 tool 名和 JSON args
  - 用户明确要走通用工具入口
  - 需要把 `image.generate`、`image.edit`、`image.import` 统一成同一种调用形态
- `inspect <tool>` 只编译和展示工具调用，不执行真实请求
- `config validate` 用来确认配置目录能否被成功加载
- `verify` 会发真实请求，可能消耗 provider 配额，不要把它当成无副作用 smoke test
- 默认输出格式：
  - `providers` / `models` / `model` 默认 `text`
  - `inspect` 默认 `json`
  - `generate` / `edit` / `import` / `run` / `verify` 默认 `text`
- discovery 命令支持 `text` 或 `json`
- `inspect` / `run` 使用的是 tool 名，不是模型名：
  - `image.generate`
  - `image.edit`
  - `image.import`
- 默认配置目录是：
  - `$XDG_CONFIG_HOME/imagine`
  - 未设置 `XDG_CONFIG_HOME` 时回落到 `~/.config/imagine`
- 如果用户明显在当前 repo 内工作，优先补：
  - `--config ./examples`

## Default Workflow

默认必须按这个顺序执行，不要跳步：

1. 先读这个 skill，确认不要先看 raw config、schema 或源码
2. 执行 `imagine providers`
3. 执行 `imagine models`
4. 执行 `imagine model <model>`
5. 根据模型能力决定走 `generate`、`edit` 还是 `import`
6. 只有当请求形状、参数合并、输出路径或 tool-level 输入可疑时，才执行 `imagine inspect <tool>`
7. 默认执行具名命令：`imagine generate`、`imagine edit`、`imagine import`
8. 只有当用户已经准备好 tool 名和 JSON args，或明确要求统一入口时，才执行 `imagine run <tool>`
9. 如果怀疑配置目录有问题，执行 `imagine config validate`
10. 只有当用户明确要验证真实连通性，或前面步骤仍无法解释 provider 侧失败时，才执行 `imagine verify`

不要一上来就跑 `verify`，也不要一上来就读本地 TOML、schema JSON 或源码。

如果怀疑当前运行环境用的不是预期配置目录，先把命令切成带 `--config <dir>` 的形式再看结果，不要先去翻原始配置文件。

## Step-By-Step Command Use

### Step 1: Find The Providers

先用：

```bash
imagine providers
```

目标：

- 确认有哪些 provider
- 粗看配置目录是否被成功加载
- 判断是否需要补 `--config <dir>`

### Step 2: Find The Models

再用：

```bash
imagine models
```

必要时缩小范围：

```bash
imagine models --provider <provider>
imagine models --operation generate
imagine models --operation edit
```

目标：

- 确认目标 model 是否真实存在
- 确认它属于哪个 provider
- 粗看它支持哪类 operation

### Step 3: Read The Model Summary

执行前必须用：

```bash
imagine model <model>
```

重点看：

- provider
- 支持的 capability
- schema / request / parser 摘要
- 这个模型更适合 `generate` 还是 `edit`

如果 `model <model>` 已经说明它不支持目标 operation，就不要直接硬跑执行命令。

### Step 4: Choose The Execution Path

默认按任务类型选命令：

- 生图：`imagine generate`
- 改图：`imagine edit`
- 导入外部图片：`imagine import`

只有在用户已经有 tool-level JSON args 时，才优先考虑：

```bash
imagine run image.generate
imagine run image.edit
imagine run image.import
```

### Step 5: Use `inspect` Only When Needed

只有下面场景才跑：

- 不确定最终 tool args 是否合并正确
- 不确定 `--args-file`、`--args`、`--arg`、显式 flags 的覆盖关系
- 不确定 output dir、output name、response format 是否落到预期结果
- `run` / `generate` / `edit` 失败后，需要确认最终编译结果

常见形态：

```bash
imagine inspect image.generate --args '{"model":"gemini-2.5-flash-image","prompt":"otter"}'
imagine inspect image.edit --args '{"model":"gemini-2.5-flash-image-edit","prompt":"poster"}'
imagine inspect image.generate --args-file ./args.json
```

不要把 `inspect` 变成每次都跑的默认第一步。

### Step 6: Run The Named Command

默认优先用具名命令：

```bash
imagine generate --model <model> --prompt "..."
imagine edit --model <model> --prompt "..." --image <path-or-url>
imagine import --item '{"type":"url","value":"https://example.com/image.png"}'
```

关于参数合并，优先记这个顺序：

```text
--args-file -> --args -> --arg key=json -> 显式 flags
```

也就是：

- `--args-file` 先给出基础 JSON object
- `--args` 再整体覆盖
- `--arg key=json` 逐项覆盖
- `generate` / `edit` 上的显式 flags 最后覆盖

默认优先使用 `text` 输出；只有用户明确需要结构化输出时，才切到 `--format json`。

### Step 7: Check Output Behavior

执行 `generate`、`edit`、`import`、`run`、`verify` 时，重点关注：

- 是否指定了 `--output-dir`
- 输出文件是否落在预期目录
- 是否生成或更新了 `.imagine-assets.json`

`.imagine-assets.json` 是运行时产物摘要，不是默认交互接口。正常情况下只需要关注最终输出文件路径，不要把 manifest 当成首选入口。

### Step 8: Validate Config Only When Needed

如果怀疑问题出在配置目录，而不是模型输入或 provider 执行，才跑：

```bash
imagine config validate
```

如果用户明显在当前 repo 内工作，优先改成：

```bash
imagine --config ./examples config validate
```

### Step 9: Use `verify` Carefully

只有下面情况才考虑：

- 用户明确要求做真实连通性验证
- 已经确认 discovery 和 `inspect` 没有解释问题
- 需要验证 provider endpoint、auth 和最小合法参数是否真的可跑通

常见形态：

```bash
imagine verify
imagine --config ./examples verify
```

`verify` 会发真实请求，可能受网络、代理、配额和上游 provider 行为影响。不要把它当成无成本命令。

## Discovery First

优先用 discovery 子命令回答这些问题：

- 有哪些 provider：`imagine providers`
- 有哪些 model：`imagine models`
- 某个 model 支持什么能力：`imagine model <model>`
- 当前配置目录是否能被加载：`imagine providers` 或 `imagine config validate`

这些命令是默认信息入口，不推荐先去读：

- `~/.config/imagine`
- `examples/*.toml`
- `examples/schemas/**/*.json`
- `internal/`

## File Reading Policy

- 正常使用时，不读取 `~/.config/imagine`
- 正常使用时，不读取 repo 里的 `examples/*.toml`
- 正常使用时，不读取 schema JSON
- 正常使用时，不通过 `internal/` 源码倒推用户命令
- 优先使用 `providers`、`models`、`model`、`inspect`、`config validate` 获取信息
- 需要切换配置目录时，优先使用 `--config <dir>`
- 只有当内置子命令已经不足以解释问题时，才允许读取具体 config 文件作为最后兜底
- 即使进入兜底排障，也只做针对性的少量读取，不把扫目录当成默认流程

## Canonical Commands

常用命令形态：

```bash
imagine providers
imagine models
imagine models --provider <provider>
imagine models --operation generate
imagine model <model>
imagine generate --model <model> --prompt "..."
imagine edit --model <model> --prompt "..." --image <path-or-url>
imagine import --item '{"type":"url","value":"https://example.com/image.png"}'
imagine inspect image.generate --args '{"model":"<model>","prompt":"..."}'
imagine run image.generate --args '{"model":"<model>","prompt":"..."}'
imagine config validate
imagine verify
```

如果用户明显在当前 repo 内工作，再考虑统一补：

```bash
--config ./examples
```

## Repo-Specific Note

只有当用户明确在 `cli-imagine` 仓库里维护或调试配置时，才把下面路径当成二级入口：

- `./examples`
- `./examples/schemas`
- `./configs`

这时可以优先建议：

```bash
imagine --config ./examples providers
imagine --config ./examples models
imagine --config ./examples model <model>
imagine --config ./examples config validate
```

如果问题已经缩小到“正式配置需要重新从 YAML 源配置导出”，再考虑：

```bash
go run ./cmd/imagine config import-yaml --from ./configs --to ./examples
```

但这不是默认用户路径，不要把它写成第一步。

## Troubleshooting Reference

只在正常路径失败后，再读 [references/troubleshooting.md](references/troubleshooting.md)。
