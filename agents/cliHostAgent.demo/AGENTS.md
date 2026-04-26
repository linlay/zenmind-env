本文件只补充 `cliHostAgent.demo` 的最小执行协议；身份、能力边界和运行时环境说明以 `agent.yml`、`SOUL.md`、skills 与当前上下文为准。

## 执行原则

- 仅当任务进入真实 CLI 验证且当前可用性未知时，先做能力探测；不要把固定探测清单机械套到所有请求上。
- 涉及 `dbx`、`httpx`、`mock`、`cdp` 时，优先读取对应 `skills/<skill>/SKILL.md`；若真实 CLI skill 不存在，再走 CLI 自带 `--help` 或 discovery 子命令。
- 涉及浏览器打开、切换网页、导航、截图、执行 JS、查询或操作 DOM 时，必须先读取 `skills/cdp/SKILL.md`，再按其中的 `curl` + Node helper 流程操作。
- `cdp` 是 skill，不是 CLI 命令；不要执行 `cdp --help` 或 `which cdp` 作为 `cdp` skill 的探测方式。
- macOS `open` 不能作为 CDP 自动化成功证明；它只能作为非 CDP fallback，且不能替代 `/json/version`、tab list、`Page.navigate`、`Runtime.evaluate` 等 CDP 验证。
- 优先使用 CLI 暴露的稳定命令面，不直接猜参数，也不把原始 config、state、local 文件当作默认入口。

## 校验纪律

- 关键探测、读取、运行、登录、修改、导入导出或状态变更后，必须再次用真实命令校验结果。
- 校验优先基于退出码、stdout/stderr、后续查询、文件存在性或状态摘要，不以推断代替证据。
- 发现 CLI 缺失、子命令不存在、配置缺失、权限不足、登录态不可用或状态不一致时，明确报告 blocker，不把失败写成成功。

## 结果交付

- 先用简洁自然语言说明这次实际完成了什么验证，再补充必要的关键证据。
- 只输出与本次任务真实相关的内容；没有对应结果时，不补空栏目或模板化占位。
- 只有当任务较复杂、需要审计或失败原因需要举证时，才补充关键步骤。
- 若产生文件或状态变化，明确给出宿主机路径，并至少做一次二次验证。
