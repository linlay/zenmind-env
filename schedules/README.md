# schedules

## 1. 目录简介

这个目录存放计划任务配置。正式计划与 example 模板可以提交，`*.demo.yml` 仅用于本地演示和验证，不作为正式工作区资产。

## 2. 如何制作一个计划任务配置

新增一个计划任务时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定任务名称 `name` 和用途 `description`。
2. 再配置是否启用 `enabled`。
3. 写清调度表达式 `cron`。
4. 如果这是限次或一次性任务，补充 `remainingRuns`。
5. 指定执行该任务的 `agentKey`。
6. 如果有时区或环境要求，补充 `environment`。
7. 在 `query.message` 中写入实际要发给 agent 的任务内容。

可参考的最小骨架：

```yaml
name: 示例计划任务
description: 说明这个任务的用途
enabled: false
cron: "17 9 * * *"
remainingRuns: 1
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
- `remainingRuns`：剩余可执行次数；`1` 等价于一次性任务。
- `agentKey`：要执行任务的 agent 标识。
- `environment`：环境信息，常见是 `zoneId`。
- `query`：发给 agent 的任务载荷，常见是 `message`。

配置事实以 YAML 为准，README 只说明如何编写和命名。

## 4. 运行时行为

- `cron` 使用传统 5 段格式：`分 时 日 月 周`。
- 5 段从左到右依次表示：
  - 第 1 段：分
  - 第 2 段：时
  - 第 3 段：日（day of month）
  - 第 4 段：月
  - 第 5 段：周（day of week）
- 例如 `17 9 * * *` 表示每天 `09:17` 执行；`*/5 * * * *` 表示每 5 分钟执行一次。
- 这是传统标准的 5 段 schedule 表达式，不支持 6 段或秒级调度。
- 服务运行中会监听这个目录；新增、修改、删除、重命名 `*.yml` / `*.yaml` 文件都会自动生效。
- `remainingRuns` 仅支持正整数。
- 限次任务每次到达触发时刻都会先扣减次数，再执行任务；不区分下游成功还是失败。
- 当 `remainingRuns` 递减到 `0` 时，对应 YAML 会被自动删除。
- 限次任务被系统回写或删除后，不再承诺保留原文件注释、空行和字段顺序。

## 5. 命名与使用约定

- 每个计划任务使用一个独立 `*.yml` 文件。
- 正式计划任务使用正常文件名。
- 示例模板使用 `*.example.yml`。
- 本地演示或试验使用 `*.demo.yml`，不作为正式工作区资产。
- 新增正式任务时，优先确认关联 `agentKey` 已存在且为正式 agent。

## 6. 提交边界

- 可提交：正式计划任务、`*.example.yml` 模板。
- 不提交：`*.demo.yml` 试验任务和仅面向本地环境的临时调度。
