---
name: "schedule"
description: "Use this skill for reminder and scheduling requests: create one-time or recurring schedules from natural language, inspect existing schedules, update or delete schedule YAML files in the schedule configuration directory, and explain cron-backed scheduling behavior without routing through platform_admin."
---

# schedule

先读这个 skill，再处理提醒、定时任务和 schedule。

这个 skill 是计划任务目录中 schedule YAML 的唯一入口。不要再把 schedule 相关请求路由给 `platform_admin`。

## 适用范围

- 用户说“3 分钟后提醒我喝水”“明天 9 点提醒我开会”
- 用户说“每天/每周/工作日提醒我……”
- 用户说“有哪些提醒”“看看已有 schedule”
- 用户说“把这个提醒改成 5 点”“删掉这个提醒”“停用这个任务”
- 用户问 schedule 的 `cron`、`enabled`、`remainingRuns`、`agentKey`、`query.message`

## Core Rules

- 先判断是创建、查看、修改还是删除
- 查看或修改前先列目录，再读目标文件头部；真正修改前再读全文
- 相对时间词必须先落成绝对时间，再生成 schedule
- `cron` 只支持传统 5 段格式：分 时 日 月 周
- 不支持秒级调度；用户提到秒级时必须明确说明限制
- 一次性提醒默认写 `remainingRuns: 1`
- 重复提醒默认不写 `remainingRuns`
- 未明确 agent 时默认 `agentKey: zenmi`
- 未明确时区时默认 `environment.zoneId: Asia/Shanghai`
- 不要自行假设目录短路径；需要具体路径时，以运行时上下文给出的计划任务目录为准
- `query.message` 直接写最终提醒文案，不要写成模糊的占位语

## 默认工作流

1. 先读 `references/intent-routing.md`，确定请求属于哪一类
2. 涉及 schedule 字段或 YAML 契约时，读 `references/schedules.md`
3. 涉及自然语言转 cron 或文件命名时，读 `references/recipes.md`
4. 查看已有任务时，先列出计划任务目录，再定点读取目标文件
5. 修改或删除前，先确认目标 schedule 已被正确定位
6. 写入后必须回读结果，核对 `cron`、`remainingRuns`、`agentKey`、`query.message`

## 默认回答与行为

- 没有时间信息的提醒请求，要先补齐时间，不直接创建
- 如果用户给的是模糊时间但能安全落成绝对时间，可以直接解释后执行
- 如果存在多个可能匹配的 schedule，要先列出候选，再继续改或删
- 查看类请求优先给简明摘要，不先大段转录 YAML
- 删除类请求默认删除对应文件；如果用户明确要保留历史，可改为 `enabled: false`

## References

- `references/intent-routing.md`
- `references/schedules.md`
- `references/recipes.md`
