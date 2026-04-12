# Recipes

## 默认字段

- `enabled: true`
- `agentKey: zenmi`
- `environment.zoneId: Asia/Shanghai`
- 无明确要求时不写 `teamId`
- `query.message` 直接写最终提醒文案

## 文件命名

- 默认格式：`reminder_<slug>_<yyyymmdd_hhmm>.yml`
- `slug` 取提醒主题的简短 ASCII 片段；拿不到时用 `task`
- 若文件名冲突，在末尾追加 `_2`、`_3`

## 一次性提醒

适用示例：

- “3 分钟后提醒我喝水”
- “明天 09:00 提醒我开会”
- “今晚 8 点提醒我给客户回信”

处理步骤：

1. 先把相对时间换成绝对日期时间
2. 生成只命中该日期时间的 5 段 cron
3. 写 `remainingRuns: 1`
4. `description` 写成简短可读的执行说明
5. `query.message` 写成最终提醒内容

建议模板：

```yaml
name: 喝水提醒
description: 2026-04-12 15:03 提醒喝水
enabled: true
cron: "3 15 12 4 *"
remainingRuns: 1
agentKey: zenmi
environment:
  zoneId: Asia/Shanghai
query:
  message: 现在去喝水。
```

## 周期提醒

适用示例：

- “每 2 分钟提醒我休息”
- “每天下午 3 点提醒我开会”
- “每周一 9 点提醒我写周报”
- “工作日 18:00 提醒我写日报”

处理规则：

- “每 N 分钟” => `*/N * * * *`
- “每天 HH:MM” => `MM HH * * *`
- “每周一 HH:MM” => `MM HH * * 1`
- “工作日 HH:MM” => `MM HH * * 1-5`
- 周期任务默认不写 `remainingRuns`

## 查看与摘要

- 先列 `/schedules`
- 默认只展示：
  - 文件名
  - `name`
  - `enabled`
  - `cron`
  - `remainingRuns`
  - `query.message`
- 只有用户明确要看全文时，再转录完整 YAML

## 修改

- 改时间：更新 `cron`，必要时同步更新 `description`
- 一次性改成周期：删除 `remainingRuns`
- 周期改成一次性：补上 `remainingRuns: 1`
- 改提醒内容：更新 `query.message`

## 删除或停用

- 默认删除对应 schedule 文件
- 用户要求“停用/暂停”时，保留文件并改 `enabled: false`
