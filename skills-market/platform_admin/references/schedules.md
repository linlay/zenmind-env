# Schedules

schedule 文件在容器内位于 `/schedules/<schedule-id>.yml`。

## 头部与字段顺序

- 前两行固定：
  - `name: ...`
  - `description: ...`
- `description` 仅支持单行披露，不要写成 `|` 或 `>` 多行块
- 推荐字段顺序：
  - `name`
  - `description`
  - `enabled`
  - `cron`
  - `remainingRuns`
  - `agentKey`
  - `teamId`
  - `environment`
  - `query`

## 必填字段

- `name`
- `description`
- `cron`
- `agentKey`
- `query.message`

## 可选字段

- `enabled`
- `remainingRuns`
- `teamId`
- `environment.zoneId`
- `query.requestId`
- `query.chatId`
- `query.role`
- `query.references`
- `query.params`
- `query.scene`
- `query.hidden`

## 约束

- `cron` 使用传统 5 段格式：分 时 日 月 周
- 5 段从左到右依次是：第 1 段分、第 2 段时、第 3 段日、第 4 段月、第 5 段周
- `17 9 * * *` 表示每天 09:17 执行，`*/5 * * * *` 表示每 5 分钟执行一次
- 不支持 6 段或秒级调度
- `remainingRuns` 仅支持正整数；`1` 等价于一次性任务
- 不支持旧顶层字段 `zoneId` 与 `params`
- `query` 必须是对象，不要写成字符串
- `query` 只应包含本页列出的受支持字段；未知 `query.*` 字段会被视为无效
- 不要写 `query.stream`
- 不要把 `agentKey` 或 `teamId` 放进 `query`
- 若填写 `teamId`，确保 `agentKey` 属于该 team
- 运行中新增、修改、删除、重命名 schedule 文件会自动生效
- 带 `remainingRuns` 的任务每次触发都会先扣减次数，再执行 dispatch；dispatch 失败也会消耗次数
- 当 `remainingRuns` 递减到 `0` 时，schedule 文件会被自动删除
- 被系统回写过的限次 schedule，不再保证保留原注释、空行与字段顺序

## 最小模板

```yaml
name: 每日摘要
description: 每天早上 9 点生成摘要
enabled: true
cron: "17 9 * * *"
remainingRuns: 1
agentKey: modePlain.demo
environment:
  zoneId: Asia/Shanghai
query:
  message: 请执行本次计划任务
  hidden: true
```

## 推荐检查顺序

1. `ls /schedules`
2. 只读查看概要时，先 `sed -n '1,20p' /schedules/<schedule-id>.yml`
3. 需要确认字段细节或准备修改时，再读全文
4. 写后回读并核对 `cron`、`remainingRuns`、`agentKey`、`query.message`
