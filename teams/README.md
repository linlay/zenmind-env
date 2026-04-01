# teams

## 1. 目录简介

这个目录存放团队配置，用来组织默认 agent 与可用 agent 列表。正式 team 与 example 模板可以提交，`*.demo.yml` 仅用于本地试验。

## 2. 如何配置一个 Team 文件

新增一个 team 时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定 team 名称 `name`。
2. 指定默认 agent `defaultAgentKey`。
3. 在 `agentKeys` 中列出这个 team 可用的 agent。
4. 保存为语义清晰的文件名；如果只是模板，用 `.example.yml`；如果只是本地试验，用 `.demo.yml`。

可参考的最小骨架：

```yaml
name: Example Team
defaultAgentKey: your-default-agent
agentKeys:
  - your-default-agent
  - another-agent
```

## 3. 常见字段

- `name`：team 名称。
- `defaultAgentKey`：默认进入或默认调用的 agent。
- `agentKeys`：这个 team 下允许使用的 agent 列表。

实际行为以 YAML 为准，README 只负责说明如何编写和命名。

## 4. 编写约定

- 每个 team 使用一个独立 `*.yml` 文件。
- `defaultAgentKey` 应当同时出现在 `agentKeys` 列表中。
- 新增 team 时，先确认其中引用的 `agentKey` 已在 [`agents/`](../agents) 中存在。
- 正式 team 使用正常文件名；模板使用 `*.example.yml`；本地试验使用 `*.demo.yml`。

## 5. 提交边界

- 可提交：正式 team 配置和 `*.example.yml` 模板。
- 不提交：`*.demo.yml` 演示配置或仅服务当前本地环境的临时组合。
