# Schedules

schedule 文件在容器内位于 `/schedules/<schedule-id>.yml`。系统会定时扫描这个目录，
按每个文件里的 cron 表达式触发 agent 执行；文件名（去掉 `.yml`）就是 schedule id。

## 什么时候要建 schedule

只要用户表达"周期性地做某件事"，就应该建 schedule，而不是说"我做不到"。典型触发词：

- 每天/每小时/每分钟 …
- 定时 / 定期 / 到点 / 隔多久 …
- 提醒我 / 通知我 / 每隔 N 分钟发一条 …
- 每 N 分钟 / 每周 N 一次 …

schedule 触发时，系统会以普通对话流程跑一次 agent，**agent 的回复会自动推送到
`query.chatId` 指定的会话**。只要把 `query.chatId` 设成当前会话 id，就实现了"每 N 分钟
自动推送消息给当前用户"。

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

- `enabled`（默认 true）
- `teamId`
- `environment.zoneId`
- `query.requestId`
- `query.chatId`（**要推送到某个会话必填**，值填当前会话 id）
- `query.role`
- `query.references`
- `query.params`
- `query.scene`
- `query.hidden`

## 约束

- `cron` 使用传统 **5 段格式**：`分 时 日 月 周`，不是 6 段。例如：
  - `* * * * *` 每分钟
  - `*/5 * * * *` 每 5 分钟
  - `0 9 * * *` 每天 9:00
  - `0 9 * * 1` 每周一 9:00
- `query` 必须是对象，不要写成字符串
- `query` 只应包含本页列出的受支持字段；未知 `query.*` 字段会被视为无效
- 不要写 `query.stream`
- 不要把 `agentKey` 或 `teamId` 放进 `query`
- 若填写 `teamId`，确保 `agentKey` 属于该 team

## chatId 从哪里取

每次 run 的系统 prompt 里都有一段 `Runtime Context: Session Context`，第一行就是
`chatId: <值>`。把这个值原样写到 `query.chatId` 即可。

## 最小模板（推送到当前会话）

这是你最常要用的形态：用户在当前对话里要求定时提醒，你据此新建 schedule。

```yaml
name: 每 30 分钟喝水提醒
description: 定时提醒用户喝水
enabled: true
cron: "*/30 * * * *"
agentKey: <当前 agent 的 key>
environment:
  zoneId: Asia/Shanghai
query:
  chatId: "<从 Runtime Context 取当前 chatId 原样填入>"
  message: "你是定时提醒助手。请生成一条喝水提醒并直接输出，不要任何前缀/后缀/反问。格式：叮~ 当前时间 HH:MM，记得喝水。"
```

关键点：
- `agentKey` 通常沿用当前 agent，除非用户明确指定
- `query.chatId` 必须是当前会话的 chatId，这样回复才会推给这个用户
- `query.message` 是每次触发时"喂给 agent 的 prompt"——写得具体一些，让 agent 输出稳定单行提醒文本，避免它反问或解释
- 文件名 = id，建议用 `chat-<chatId 前 8 位>-<简短描述>.yml` 形式便于检索

## 常见错误（一定要避开）

1. **不要复制 `/schedules/` 下现成示例的内容**。那个目录里可能有**整段注释掉**的模板文件（每行都以 `#` 开头），直接抄过来系统会把整份 YAML 当空文件跳过，什么也不会触发。**只参照本页"最小模板"写新的 YAML**。
2. **不要在行首加 `#`**。YAML 里 `#` 是注释，整行会被忽略。
3. **不要在 `message` 里写占位符**（例如 `{time}`、`{{date}}`、`${now}`）。系统**不做字符串替换**，`query.message` 会原样作为 prompt 喂给 agent。要让消息带当前时间，应该在 prompt 里明确要求 agent **调 `_datetime_` 工具**取值，然后直接写进输出，例如：
   - 正确：`"先调用 _datetime_ 获取当前时间 HH:MM，然后直接输出一行：叮~ 当前时间 <HH:MM>，记得喝水，不要附加解释。"`
   - 错误：`"叮~ 当前时间 {time}，记得喝水"`（`{time}` 会被原样展示）
4. **写完必回读**：`cat /schedules/<文件名>.yml`，确认不是全注释、缩进正确、`chatId` 是当前会话、`cron` 是 5 段。

## 最小模板（后台跑不推送）

如果只是后台任务、不需要回给某个人（比如每天清理日志），就不填 `query.chatId`，
同时建议 `query.hidden: true`：

```yaml
name: 每日清理
description: 每天凌晨做清理
enabled: true
cron: "0 3 * * *"
agentKey: modePlain.demo
environment:
  zoneId: Asia/Shanghai
query:
  message: 请执行日常清理
  hidden: true
```

## 操作步骤

### 新建（响应用户的周期性请求）

1. 从 `Runtime Context` 读当前 `chatId`、当前 `agentKey`
2. 跟用户确认 cron 频率和提醒内容（可缺省合理默认）
3. 生成文件名：`chat-<chatId 前 8 位>-<简短描述>.yml`
4. 用 bash 写入 `/schedules/<文件名>.yml`
5. 回读验证：`cat /schedules/<文件名>.yml`
6. 简短告知用户已创建、cron 频率、如何取消（"跟我说停/删掉这个提醒"）

### 查询（用户问"我有哪些定时任务"）

1. `ls /schedules`
2. 用 `grep -l '"<chatId>"' /schedules/*.yml` 找出归属当前会话的任务
3. 逐个 `sed -n '1,20p'` 披露 name / cron / message

### 删除（用户要取消）

1. 先用查询步骤找到对应文件
2. 确认文件里的 `query.chatId` 跟当前会话一致，避免误删别的会话的任务
3. `rm /schedules/<文件名>.yml`
4. 回读 `ls /schedules` 确认已删

## 推荐检查顺序

1. `ls /schedules`
2. 只读查看概要时，先 `sed -n '1,20p' /schedules/<schedule-id>.yml`
3. 需要确认字段细节或准备修改时，再读全文
4. 写后回读并核对 `cron`、`agentKey`、`query.chatId`、`query.message`
