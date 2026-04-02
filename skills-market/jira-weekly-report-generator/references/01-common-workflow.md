# 通用工作流

## 1. 识别项目

- 先从用户输入识别项目别名
- 再路由到对应 project reference
- 不允许在没有 project reference 的情况下直接沿用别的项目格式

## 2. 解析时间

- “本周”“上周”“最近一周”等相对时间词，必须先转成绝对起止日期
- 最终周报正文必须显式写出绝对日期区间
- 生成 Jira 查询和最终结论时都使用同一套绝对日期

## 3. 走 `httpx` 标准路线

涉及 Jira 时，必须先读取 `/skills/httpx/SKILL.md`，然后按最小闭环执行：

1. `httpx sites`
2. `httpx site jira.gtjaqh.net`
3. `httpx actions jira.gtjaqh.net`
4. `httpx action jira.gtjaqh.net <action>`
5. `httpx state jira.gtjaqh.net`
6. 项目解析
7. 时间区间解析
8. JQL 生成
9. 必要时 `inspect`
10. 最后 `run`

## 4. 周报事实组织

周报里的事实分两类：

- 动态事实：来自本次 Jira 查询和当前输入补充
- 稳定模板事实：来自项目 reference 的章节顺序、表头和运营口径

生成时必须先分清：

- 哪些是“当前周真实数据”
- 哪些是“模板结构”
- 哪些是“补充备注/风险说明”

## 5. Markdown 优先

- 默认先生成结构化 Markdown
- Markdown 是后续 DOCX 的唯一内容源
- 不要跳过 Markdown 直接拼接 Word XML 或直接写随机版式

## 6. DOCX 路线

当用户明确要求 Word 时：

1. 先读取 `/skills/docx/SKILL.md`
2. 先在工作目录写出 Markdown
3. 再把 Markdown 转成 `.docx`
4. 产物必须再做存在性和格式校验

## 7. 失败与阻塞

- 项目候选不唯一时，必须返回候选，不能猜默认项目
- 缺少 project reference 时，必须明确报告 blocker
- 缺少登录态、Jira 不可访问或统计口径无法确认时，必须明确标注不确定项
- 月报请求不归这个 skill 处理，应说明需要独立的月报 skill/agent
