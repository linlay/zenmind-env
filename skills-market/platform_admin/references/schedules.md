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

- `cron` 使用 Spring 6 段格式：秒 分 时 日 月 周
- 不支持旧顶层字段 `zoneId` 与 `params`
- `query` 必须是对象，不要写成字符串
- `query` 只应包含本页列出的受支持字段；未知 `query.*` 字段会被视为无效
- 不要写 `query.stream`
- 不要把 `agentKey` 或 `teamId` 放进 `query`
- 若填写 `teamId`，确保 `agentKey` 属于该 team

## 最小模板

```yaml
name: 每日摘要
description: 每天早上 9 点生成摘要
enabled: true
cron: "0 0 9 * * *"
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
4. 写后回读并核对 `cron`、`agentKey`、`query.message`
