---
name: "mock"
description: "Use this skill when the user wants to use cli-mock to simulate stdout/stderr/exit behavior, test args/env/stdin/stream flows, or create and inspect mock XDG-style .config and .local trees with `mock xdg`."
---

# mock

先读这个 skill，再操作 `mock`。

把 `mock` 当成一个可预测的测试 CLI：优先选最小、最稳定、最容易断言的命令，不要把它当成通用 shell 替代品。

## What It Covers

- 基础命令模拟：`echo`、`stderr`、`exit`、`fail`
- 结构化输出：`json`、`args`、`lines`
- 运行环境读取：`env`、`stdin`
- 延迟与流式输出：`sleep`、`stream`
- XDG 环境树：`xdg apply`、`xdg inspect`

## Default Workflow

1. 先判断需求属于哪条路线：
   - 基础命令模拟
   - XDG 环境树
2. 如果只是要模拟输出、退出码、stdin、env 或流式文本，走基础命令路线。
3. 如果目标是准备或检查 `.config` / `.local` 下的可直接使用环境，走 XDG 路线。
4. XDG 路线优先执行 `mock xdg inspect`，只有在需要创建或更新环境树时才执行 `mock xdg apply`。
5. 只有确实需要文件内容时才在 `inspect` 里加 `--reveal`；默认先看 metadata。

## Basic Command Route

- 输出一行文本：`mock echo <text...>`
- 输出到 stderr：`mock stderr <text...>`
- 模拟失败：`mock fail [message...]`
- 指定退出码：`mock exit <code>`
- 验证 JSON：`mock json <raw-json>`
- 读取环境变量：`mock env <key>`
- 回显 stdin：`mock stdin`
- 生成固定行：`mock lines <count>`
- 生成带延迟输出：`mock stream <count> [content...] --interval <duration>`

如果问题是“这个命令适不适合这个测试场景”“应该用哪个子命令”，先读 `references/commands.md`。

## XDG Route

当前稳定入口：

- `mock xdg apply --root <dir> --manifest <path-or-> [--overwrite]`
- `mock xdg inspect --root <dir> [--reveal]`

默认规则：

- `--root` 是显式 fake home root，不会默认改写真实 home
- v1 manifest 只支持 JSON
- 只允许创建或读取 `.config/**` 与 `.local/**`
- `inspect` 默认只看路径、类型、权限和大小
- `--reveal` 只用于查看 UTF-8 文本或 JSON 文件内容

如果问题是“manifest 怎么写”“什么时候用 apply / inspect”“为什么路径被拒绝”“什么时候该 reveal”，先读 `references/xdg-env.md`。

## References

- `references/commands.md`
- `references/xdg-env.md`
