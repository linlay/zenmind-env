# Chats

当前工作区 chat 数据位于 `/chats`，主文件格式以 `.jsonl` 为准。

## 结构事实

- 主记录文件通常是 `/chats/<chatId>.jsonl`
- 也可能存在同名目录 `/chats/<chatId>/`，用于存放该 chat 的附件或生成文件
- JSONL 表示一行一条 JSON 记录，应按“逐行事件/步骤”理解，而不是整文件一个 JSON

## 默认权限

- 只读浏览
- 可以做：
  - 按 `chatId` 定位
  - 统计行数与最近更新时间
  - 抽取结构、阶段、错误、工具调用线索
  - 总结主题与关键问题
- 默认不要做：
  - 改写历史
  - 大段转录原始对话
  - 暴露敏感附件路径或用户隐私

## 推荐检查顺序

1. `ls /chats | head`
2. `ls /chats/<chatId> 2>/dev/null` 按需查看附件目录
3. `sed -n '1,20p' /chats/<chatId>.jsonl`
4. `tail -n 20 /chats/<chatId>.jsonl`
5. 需要定位关键词时用 `rg`

## 输出纪律

- 总结结构和结论，不默认贴原文
- 若必须引用，保持最小片段并避免敏感字段
- 无明确要求时，不建议编辑 chat 历史
