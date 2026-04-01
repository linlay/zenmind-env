# registries.example

## 1. 目录简介

这个目录是工作区 registry 的模板事实源，负责提供可提交、可打包的 models/providers/MCP/viewport 配置。与之对应的 `registries/` 是本地 live 运行态目录，不作为仓库事实源。

## 2. 子目录说明

- [`models/`](./models)：模型定义模板。
- [`providers/`](./providers)：上游 provider 定义模板。
- [`mcp-servers/`](./mcp-servers)：MCP server 模板。
- [`viewport-servers/`](./viewport-servers)：viewport server 模板。

## 3. 使用约定

- 调整共享模板时，优先改 `registries.example/`。
- 初始化或同步本地工作区时，再把模板复制到 `registries/`。
- 模板目录中的 `*.yml` 是事实源，README 只解释目录职责和分类关系。

## 4. 提交边界

- 可提交：模板配置、分类说明、结构化 README。
- 不提交：本地 `registries/` live 变更、临时调试配置和私有凭据。

## 5. 维护建议

- 目录职责尽量保持清晰：provider 级行为写在 `providers/`，模型特例优先写在 `models/`。
- 新增分类时，要同步更新上级 [`README.md`](../README.md) 中的目录说明。
