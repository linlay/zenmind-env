# tools

## 1. 目录简介

这个目录存放 ZenMind 平台可注册的前端/交互工具定义。这里的 `*.yml` 是正式配置，可提交到 Git，但当前不属于发布包主内容。

## 2. 如何配置一个 Tool 文件

新增一个 tool 时，建议为它创建一个独立的 `*.yml` 文件。

建议步骤：

1. 先确定稳定的 `name`。
2. 写清展示名称 `label` 和用途 `description`。
3. 指定 `type`，通常是 `function`。
4. 如果这是可供平台调用的动作，写上 `toolAction: true`。
5. 在 `inputSchema` 中定义参数结构、类型和必填项。

可参考的最小骨架：

```yaml
name: your_tool_name
label: 工具名称
description: 说明这个工具是做什么的
type: function
toolAction: true
inputSchema:
  type: object
  properties: {}
  additionalProperties: false
```

## 3. 常见字段

- `name`：工具的稳定标识，建议与文件名语义一致。
- `label`：给用户或界面展示的名称。
- `description`：工具用途说明。
- `type`：工具类型，当前常见为 `function`。
- `toolAction`：是否作为平台可调用动作暴露。
- `inputSchema`：工具参数定义，通常使用 JSON Schema 风格。

工具事实以 YAML 为准，README 只负责说明如何编写。

## 4. 编写约定

- 每个工具使用一个独立 `*.yml` 文件定义。
- 一个文件只描述一个 tool。
- 参数变更时，应直接更新 `inputSchema`，不要只改文档。
- 如果某个动作需要前端展示或调用，字段命名要尽量稳定，避免频繁改 `name`。

## 5. 提交边界

- 可提交：正式工具定义文件。
- 不建议在这里放 demo、临时测试稿或运行态产物。
