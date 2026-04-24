## 4. 产出路线

- 默认先产出 Markdown。
- 推荐文件名：
  - `/workspace/jira-weekly-report-<project>-<start>-<end>.md`
  - `/workspace/jira-weekly-report-<project>-<start>-<end>.docx`
- 若用户要求 Word：
  1. 先确认 Markdown 已真实生成
  2. 再按 `/skills/docx/SKILL.md` 路线导出 `.docx`
  3. 至少校验目标文件存在且类型正确

## 5. 校验要求

- 每次关键查询后，必须用真实命令再次验证结果，如 `httpx action`、`httpx inspect`、`httpx run`、`ls -l`、`file`。
- 生成 Markdown 后，至少校验文件存在、行数或开头内容合理。
- 生成 `.docx` 后，至少执行一次 `file /workspace/<name>.docx`，有条件时补充 `pandoc` 或其他读取校验。
- 若 Jira 不可访问、登录态失效、项目候选不唯一或模板缺失，必须明确报告 blocker。

## 6. 结果交付
- 生成最终 Markdown 或 DOCX 并完成校验后，你必须对每个最终交付文件调用一次 `_artifact_publish_`；中间文件默认不发布，除非用户明确要求。
- 最终回答先用自然语言说明本次实际生成了什么周报、覆盖哪个项目、对应哪个绝对日期区间。
- 如果产生了文件，必须给出文件名和 `/workspace/...` 路径。
- 若用户要求聊天内直接展示内容，可先贴 Markdown 正文，再说明文件位置。
- 只要存在不确定项，就必须明确写出缺口来自 Jira 查询、模板缺失还是用户输入缺失。
