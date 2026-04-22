# Agents

当前工作区的 agent 在容器内位于 `/agents/<agent-key>/`，推荐目录化布局。

## 必须先知道的契约

- 主配置文件固定为 `/agents/<agent-key>/agent.yml`
- `agents/<agent-key>/` 目录名必须与 `agent.yml` 里的 `key` 一致，否则 runner 会跳过该 agent
- `agent.yml` 前 4 行固定为：
  - `key`
  - `name`
  - `role`
  - `description`
- 这 4 行都应保持单行 inline value，便于渐进式披露
- 除前 4 行外，后续字段没有强制语义顺序，但新写或重排 `agent.yml` 时优先使用这组推荐顺序：
  - `icon`
  - `modelConfig`
  - `toolConfig`
  - `skillConfig`
  - `contextConfig`
  - `sandboxConfig`
  - `mode`
  - `budget`
  - `react` 或 `planExecute`
  - `wonders`
- 常见伴随文件：
  - `SOUL.md`
  - `AGENTS.md`
  - `AGENTS.plan.md`
  - `AGENTS.execute.md`
  - `AGENTS.summary.md`
  - `memory/`
  - `skills/`
  - `tools/`

## 什么时候改哪个文件

- 改模型、工具、mode、skills、sandbox、icon、description：改 `agent.yml`
- 改长期角色边界、价值观、权限纪律：改 `SOUL.md`
- 改执行步骤、读写流程、回答格式、验证要求：改 `AGENTS.md`
- 仅在 `PLAN_EXECUTE` agent 中，规划/执行/总结分阶段 prompt 才拆到 `AGENTS.plan.md`、`AGENTS.execute.md`、`AGENTS.summary.md`

## 当前任务最相关字段

- `modelConfig.modelKey`
- `modelConfig.reasoning.enabled`
- `modelConfig.reasoning.effort`
- `toolConfig.tools`
- `skillConfig.skills` 或 `skills`
- `mode`
- `react.maxSteps`
- `sandboxConfig.environmentId`
- `sandboxConfig.level`
- `sandboxConfig.extraMounts`

## extraMounts 规则

- 平台简写只在 runner 已知的平台目录上使用
- 自定义挂载需要：
  - `source` 指向存在的目录
  - `destination` 是绝对路径
  - 不与已有容器路径冲突
- 只暴露完成任务所需目录，不要无差别扩权

## 推荐检查顺序

1. `ls /agents`
2. 只看概览或批量巡检时，先 `sed -n '1,4p' /agents/<agent-key>/agent.yml`
3. 需要确认配置细节时，再 `sed -n '1,40p' /agents/<agent-key>/agent.yml`
4. 真正修改前，再读 `agent.yml` 全文；需要改 prompt 时再读对应 markdown 全文
5. 修改后再 `sed -n '1,80p'` 回读关键段
