## 2. 项目与模板路由

- 用户提到 `运营 1 号`、`运营业务中台`、`OMS` 时，必须路由到 `/skills/jira-weekly-report-generator/references/projects/oms-weekly.md`。
- 若用户提到其他项目，但当前不存在对应 project reference，必须停止并说明缺少项目模板。
- 任何情况下都不能把 `OMS` 的章节结构套到别的项目上。

## 3. Jira 查询路线

- 读取 `/skills/httpx/SKILL.md` 后，默认顺序必须是：
  - `httpx sites`
  - `httpx site jira.gtjaqh.net`
  - `httpx actions jira.gtjaqh.net`
  - `httpx action jira.gtjaqh.net <action>`
  - `httpx state jira.gtjaqh.net`
- 项目候选不唯一时，必须返回候选，不允许猜默认项目。
- “本周”“上周”等相对时间词，必须先转成绝对日期区间，并在最终周报中显式写出。
- 查询结果、版本统计、条线统计与卡点描述要和项目模板的章节 contract 对齐，但不能伪造缺失数据。
