# agents

## 1. 目录简介

这个目录存放 ZenMind agent 的目录化定义。这里的 README 只说明如何制作一个新的 agent，以及 agent 目录应该如何组织；它不负责介绍当前已有哪几个 agent。

## 2. 新建一个 Agent 的基本结构

每个 agent 使用一个独立目录，通常包含以下文件：

- `agent.yml`：结构化主定义，负责名称、角色、模型、模式、工具、技能、沙箱、预算等配置。
- `SOUL.md`：角色边界、人格设定、长期行为风格。
- `AGENTS.md`：执行流程、资源使用规则、校验要求、结果交付格式。

建议目录结构如下：

```text
agents/<agent-id>/
  agent.yml
  SOUL.md
  AGENTS.md
```

提示词配置约定：

- `ONESHOT` / `REACT`：在 `agent.yml` 顶层写 `promptFile`。
- `PLAN_EXECUTE`：在 `planExecute.plan.promptFile`、`planExecute.execute.promptFile`、`planExecute.summary.promptFile` 分别写。
- `promptFile` 可以是单个字符串，也可以是字符串数组；如果写多个，会按顺序拼装成 system prompt。
- 如果不写 `promptFile`，默认读取同目录下的 `AGENTS.md`。
- `SOUL.md` 仍然负责角色边界与长期行为，不需要写进 `promptFile`。

`agent.yml` 字段顺序约定：

- 前 4 行固定为 `key`、`name`、`role`、`description`，并保持单行 inline value。
- 之后推荐依次写 `icon`、`modelConfig`、`toolConfig`、`skillConfig`、`contextConfig`、`sandboxConfig`、`mode`、`budget`、`react` 或 `planExecute`，最后再写 `wonders`。
- `wonders` 默认放在偏后位置，不建议作为紧跟描述后的第一个扩展字段。

如果只是本地演示或试验，请使用 `*.demo` 目录名，例如 `myAgent.demo/`，不要和正式 agent 混用。

## 3. 提交边界

- 可提交：正式 agent 目录下的配置与说明文件。
- 不提交：`*.demo` 目录，以及 agent 运行时同步出的本地 `skills/`、`memory/`、`experiences/` 等用户态内容。
- agent 的事实以目录内文件为准，README 只负责说明制作约定。

## 4. 三个文件分别改什么

- 改模型、模式、工具、预算、挂载时，优先改 `agent.yml`。
- 改角色边界、语气和长期行为时，优先改 `SOUL.md`。
- 改执行流程、资源治理或回答格式时，优先改 `AGENTS.md`。

## 5. 制作步骤建议

1. 先确定 agent 的目录名，也就是稳定的 `agent-id`。
2. 先写 `agent.yml`，把模型、模式、技能和沙箱边界定清楚。
3. 再写 `SOUL.md`，定义这个 agent 的角色、语气和行为边界。
4. 最后写 `AGENTS.md`，补执行步骤、验证要求和交付格式。
5. 如果只是试验方案，用 `.demo` 目录创建，不要直接占用正式名称。

## 6. 维护建议

- 一个目录只定义一个 agent，不要把多个 agent 混在同一目录。
- 文件职责尽量稳定，不要把人格说明写进 `agent.yml`，也不要把结构化配置塞进 Markdown。
- 需要了解整个工作区的其他目录边界时，回到上级 [`README.md`](../README.md)。
