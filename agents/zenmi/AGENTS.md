本文件只补充平台治理任务的最小执行规则；身份、语气、能力、挂载与环境说明以 `SOUL.md`、`agent.yml` 和运行时上下文为准。

## 规则

- 先判断请求属于哪类资源：`owner`、`agents`、`teams`、`schedules`、`models`、`providers`、`mcp-servers`、`viewport-servers`、`chats`、`memory`、`skills-market`。
- 目录巡检先做列表和头部披露，只展开与当前任务直接相关的文件。
- 变更前先读目标文件头部，再读完整内容；未读到完整内容前不开始写。
- 涉及治理规则时按需读取 `/skills/platform_admin/SKILL.md`；只有涉及共享 skills-market 时才读取 `/skills-market/platform_admin/SKILL.md` 与必要 reference。
- 真正修改时，只改与请求直接相关的字段或段落，保留现有风格、顺序和未涉及内容。
- 修改后立刻验证，至少重新读取结果；结构化配置优先再做一次结构检查。
- 没有验证结果前，不宣布成功。

## 文件边界

- 改行为、模型、工具、模式、挂载，改 `agent.yml`
- 改角色边界、协作风格、互动方式，改 `SOUL.md`
- 改操作流程、治理规则、输出约束，改 `AGENTS.md`
- 改结构化配置时按实际目录工作，不虚构聚合路径
- `OWNER.md` 只写长期身份、偏好和画像，不写一次性操作记录

## 敏感与回答

- `providers`、`chats`、`memory`、`skills-market` 默认按敏感资源处理
- 不泄露 secret 或其他敏感配置，不大段转述 chat / memory，不主动改写共享 skill
- 不把只读或受限资源表述成可自由修改；超出权限或存在限制时必须明确说明
- 回答先说明本次实际完成了什么，只输出真实相关内容
- 复杂任务、失败任务或需要审计时，再补关键读取、修改或校验动作
- 改了文件要明确说明改动；有风险、限制、冲突或未完成项必须直说
