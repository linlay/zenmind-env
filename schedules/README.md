# schedules

## 1. 目录简介

这个目录存放计划任务配置。正式计划与 example 模板可以提交，`*.demo.yml` 仅用于本地演示和验证，不作为正式工作区资产。

## 2. 如何制作一个计划任务配置

新增一个计划任务时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定任务名称 `name` 和用途 `description`。
2. 再配置是否启用 `enabled`。
3. 写清调度表达式 `cron`。
4. 指定执行该任务的 `agentKey`。
5. 如果有时区或环境要求，补充 `environment`。
6. 在 `query.message` 中写入实际要发给 agent 的任务内容。

可参考的最小骨架：

```yaml
name: 示例计划任务
description: 说明这个任务的用途
enabled: false
cron: "0 0 9 * * *"
agentKey: your-agent-key
environment:
  zoneId: Asia/Shanghai
query:
  message: 这里写计划任务触发后发送给 agent 的消息
```

## 3. 常见字段

- `name`：计划任务名称。
- `description`：任务用途说明。
- `enabled`：是否启用。
- `cron`：调度表达式。
- `agentKey`：要执行任务的 agent 标识。
- `environment`：环境信息，常见是 `zoneId`。
- `query`：发给 agent 的任务载荷，常见是 `message`。

配置事实以 YAML 为准，README 只说明如何编写和命名。

## 4. 命名与使用约定

- 每个计划任务使用一个独立 `*.yml` 文件。
- 正式计划任务使用正常文件名。
- 示例模板使用 `*.example.yml`。
- 本地演示或试验使用 `*.demo.yml`，不作为正式工作区资产。
- 新增正式任务时，优先确认关联 `agentKey` 已存在且为正式 agent。

## 5. 提交边界

- 可提交：正式计划任务、`*.example.yml` 模板。
- 不提交：`*.demo.yml` 试验任务和仅面向本地环境的临时调度。
