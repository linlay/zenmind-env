---
name: "平台总管技能"
description: "Use this skill when inspecting or changing ZenMind workspace governance resources: agents, teams, schedules, registries, owner/, chats, and skills-market. It provides the exact file contracts, sensitive-data rules, and a progressive disclosure workflow for safe edits."
---

# 平台总管技能

用这个 skill 来治理当前工作区资源，而不是凭印象直接改文件。

## Resource Map

- `/agents` -> agent 目录与 prompt 文件
- `/teams` -> team YAML
- `/schedules` -> schedule YAML
- `/registries` -> models / providers / mcp-servers / viewport-servers 等实时注册配置
- `/zenmind-root/owner` -> 用户身份与画像目录
- `/chats` -> chat JSONL 与附件目录
- `/skills` -> 当前 agent 的本地 skills
- `/skills-market` -> 共享 skills-market

## Routing

- 问、查、看、改 agent：先读 `references/agents.md`
- 改 team：先读 `references/teams.md`
- 问、查、看、改 schedule：先读 `references/schedules.md`
- 用户要"周期性/定时/每 N 分钟/每天 X 点/定期提醒或推送"：也先读 `references/schedules.md`，按其中模板新建一条 schedule，并把 `query.chatId` 设为当前会话 id
- 改模型注册配置：先读 `references/registries-models.md`
- 改 provider 注册配置：先读 `references/registries-providers.md`
- 改 MCP server 注册配置：先读 `references/registries-mcp-servers.md`
- 改 viewport server 注册配置：先读 `references/registries-viewport-servers.md`
- 改 `owner/`：先读 `references/owner.md`
- 查 chat：先读 `references/chats.md`
- 问、查、看 skills-market 或某个 skill 的能力与结构：先读 `references/skills-market.md`

组件问题示例：
- 用户问“有哪些 agent”“这个 agent 是干什么的”“它的 mode / tools / sandbox 是什么”：先读 `references/agents.md`
- 用户问“有哪些计划任务”“这个 schedule 的 cron / enabled 是什么”：先读 `references/schedules.md`
- 用户说“帮我每分钟/每天 X 点提醒我…”“设一个定时任务”“定期推送…”：先读 `references/schedules.md`，按其中“推送到当前会话”的最小模板建文件，而不是回复“我做不到主动发消息”
- 用户问“platform_admin 这个 skill 管哪些组件”：先读 `/skills-market/platform_admin/SKILL.md`，再按需读 `references/agents.md`、`references/schedules.md`、`references/teams.md` 等相关 reference

## Global Rules

1. 先判断资源类型，再读对应 reference；不要把所有 reference 一次性展开。
2. 只要用户在问某个治理组件的事实信息，而不是闲聊概念，也必须先读对应 reference，再回答；这个规则同时适用于只读问答与实际修改。
3. 修改前先看目标文件头部与完整内容；目录巡检时先做列表与头部披露。
4. agent 概览或批量巡检时，`agent.yml` 默认只披露前 4 行：`key`、`name`、`role`、`description`；只有任务需要更多字段时再继续展开。
5. 修改后必须回读结果，必要时再做结构检查；没有工具结果就不要声称成功。
6. `providers` 含敏感信息：默认只定点修改，不主动回显完整 secret。
7. `chats` 默认只读：允许总结、抽取结构、定位问题；无明确要求时不编辑历史，不大段转录原文。
8. `skills-market` 默认只读：优先阅读 `SKILL.md`，再按需读 `references/` 或 `scripts/`；不要主动改写共享 skill。
9. 保持最小改动：不要顺手重排无关字段、重命名无关文件或清洗用户未要求的内容。

## References

- `references/agents.md`
- `references/teams.md`
- `references/schedules.md`
- `references/registries-models.md`
- `references/registries-providers.md`
- `references/registries-mcp-servers.md`
- `references/registries-viewport-servers.md`
- `references/owner.md`
- `references/chats.md`
- `references/skills-market.md`
