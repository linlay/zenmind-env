---
name: "mock"
description: "Use this skill when the user wants to use cli-mock to simulate stdout/stderr/exit behavior, test args/env/stdin/stream flows, create and inspect mock XDG-style .config and .local trees with `mock xdg`, or drive mock business forms for leave, expense, and procurement."
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
- 业务表单：`create/get/update/delete` for `leave`、`expense`、`procurement`
- 表单审批链路：compose form -> `mock create-* --payload '<json>'` -> Bash HITL -> HTML viewport approval

## Default Workflow

1. 先判断需求属于哪条路线：
   - 基础命令模拟
   - XDG 环境树
   - 业务表单
2. 如果只是要模拟输出、退出码、stdin、env 或流式文本，走基础命令路线。
3. 如果目标是准备或检查 `.config` / `.local` 下的可直接使用环境，走 XDG 路线。
4. 如果目标是 mock 业务表单或验证 viewport 审批流，走业务表单路线。
5. XDG 路线优先执行 `mock xdg inspect`，只有在需要创建或更新环境树时才执行 `mock xdg apply`。
6. 只有确实需要文件内容时才在 `inspect` 里加 `--reveal`；默认先看 metadata。

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

## Business Form Route

当前这 3 个 create 流已经接入 HTML approval viewport：

- `mock create-leave --payload '<json>'` -> `leave_form`
- `mock create-expense --payload '<json>'` -> `expense_form`
- `mock create-procurement --payload '<json>'` -> `procurement_form`

默认规则：

- 构造 `--payload` 前先跑 `mock create-<leave|expense|procurement> --help`，以 CLI `--help` 里的 Example 为权威 schema
- payload 字段必须使用 `snake_case` 与 `_id` 风格；禁止 camelCase、缩写 key、或自创字段名
- 业务命令以 `cli-mock` 的真实命令面为准，不要使用不存在的 `mock expense` 或 `mock procurement`
- 优先使用 inline `--payload '<json>'`，这样宿主才能把 payload 预填到 approval viewport
- `--payload-file` / `--payload-stdin` 仍然可用，但当前 approval 预填优化只覆盖 inline `--payload`
- 当用户想“先填表单再确认”，先让表单生成 `mock create-* --payload '<json>'`
- 当命令被 skill 的 `.bash-hooks` 拦截后，会进入 `_ask_user_approval_`，并渲染对应 HTML viewport 供用户核对 payload
- approval viewport 里以核对为主；真正执行的是用户批准后的 `mock create-*` 命令

如果问题是“3 个业务分别有哪些字段”“create/get/update/delete 命令怎么写”“哪些结果枚举可用”“什么时候该走 viewport 交互”，先读 `references/business-forms.md`。

## References

- `references/commands.md`
- `references/xdg-env.md`
- `references/business-forms.md`
