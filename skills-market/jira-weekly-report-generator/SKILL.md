---
name: "jira-weekly-report-generator"
description: "用于生成 Jira 项目周报。适用于根据 Jira 数据、项目专属周报模板和运营规则产出结构化 Markdown 周报，并在用户要求时继续导出 DOCX。默认先走 httpx discovery 和项目 reference 路由，不允许直接猜项目 key、时间区间或输出格式。"
---

# Jira 周报生成器

先读这个 skill，再处理 Jira 周报。

这个 skill 只定义通用工作流和输出契约；项目差异必须从 `references/projects/` 读取，不允许把 `OMS` 这类项目专属格式硬编码进通用逻辑。

## 适用范围

- 用户要“生成 Jira 周报”
- 用户要“按项目输出周报/周总结/周进展”
- 用户需要先生成 Markdown，再按需导出 Word
- 用户明确提到项目别名，例如“运营 1 号”“运营业务中台”“OMS”

## Core Rules

- 先识别项目，再读取项目 reference
- 先用 `httpx` discovery，再决定真实查询
- 相对时间词必须先落成绝对日期区间
- 默认主交付物是 Markdown；只有用户要求 Word 时才导出 DOCX
- 周报里的事实、统计、条线结构和表头必须与项目 reference 对齐
- 项目 reference 不存在时，必须停止并说明缺少项目模板
- 周报 skill 只负责“周报”；月报由未来独立 skill `jira-monthly-report-generator` 负责

## 默认工作流

1. 识别用户说的是哪个项目，读取 `references/projects/<project>-weekly.md`
2. 读取 `references/01-common-workflow.md`
3. 读取 `references/02-output-contract.md`
4. 涉及 Jira 查询时，先读取 `/skills/httpx/SKILL.md`
5. 先做 `httpx` discovery，再做项目解析、时间区间解析和 JQL 生成
6. 把真实 Jira 结果与项目 reference 的章节 contract 对齐
7. 先输出结构化 Markdown
8. 用户要求 Word 时，再读取 `/skills/docx/SKILL.md` 并导出 `.docx`

## 项目路由

- `运营 1 号`
- `运营业务中台`
- `OMS`

以上别名统一路由到：

- `references/projects/oms-weekly.md`

后续其他项目必须新增各自的 project reference，不允许复用 `OMS` 的章节结构去猜。

## 输出要求

- 默认输出一个周报 Markdown 正文
- 若用户要求文件产物，推荐文件名：
  - `jira-weekly-report-<project>-<start>-<end>.md`
  - `jira-weekly-report-<project>-<start>-<end>.docx`
- 周报正文必须写清：
  - 项目名
  - Jira 项目 key 或唯一候选
  - 绝对日期区间
  - 数据来源
  - 风险/卡点/待办

## References

1. 通用流程：`references/01-common-workflow.md`
2. 输出契约：`references/02-output-contract.md`
3. 项目路由说明：`references/projects/README.md`
4. OMS 项目模板：`references/projects/oms-weekly.md`
