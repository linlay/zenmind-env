# CLAUDE.md

## 1. 项目概览

这是 ZenMind 智能体平台的配置工作区，主要存放智能体定义、平台工具、共享技能、模板配置和本地运行态目录。它不是面向业务接口的应用代码仓，也不是单一发布产物仓。

项目边界如下：

- 仓库事实源是目录契约、文件命名规则和 example 模板
- `demo` 内容用于本地验证或演示，可作为仓库内演示资产存在，但不作为正式发布资产
- live 运行态目录只服务当前工作区，不作为共享配置事实源

## 2. 技术栈

- 配置格式：YAML、Markdown、JSONL
- 脚本与打包：shell，当前入口为 [`package.sh`](/Users/linlay/Project/zenmind/zenmind-env/package.sh)
- 运行态目录：`root/`、`owner/`、`chats/`
- 共享资产：`agents/`、`skills-market/`、`tools/`、`teams/`，以及 `schedules/` 中的 README 与 example 模板

## 3. 架构设计

工作区按“正式配置、模板配置、本地运行态”三层组织：

- 正式配置层：`agents/`、`tools/`、`skills-market/`、`teams/`
- 模板层：`registries.example/`、`owner.example/`、`chats/` 内 example 样例、`root/` 中 `.example` 项
- 运行态层：`registries/`、`owner/`、真实 `chats/`、`root/.config`、`root/.cache`、`root/.local`

打包流程从模板层和正式配置层取材，不消费本地 live registry、真实 owner 数据或真实聊天历史。

## 4. 目录结构

- [`agents/`](/Users/linlay/Project/zenmind/zenmind-env/agents)：智能体定义目录。正式目录和 `*.demo` 演示目录都可纳入版本管理。
- `registries/`：当前工作区 live registry，本地运行态，不纳入 Git。
- [`registries.example/`](/Users/linlay/Project/zenmind/zenmind-env/registries.example)：registry 模板，作为提交与打包来源。
- [`skills-market/`](/Users/linlay/Project/zenmind/zenmind-env/skills-market)：共享技能市场，正式 skill 可提交。
- [`schedules/`](/Users/linlay/Project/zenmind/zenmind-env/schedules)：计划任务。仅 `README.md` 与 example 模板可提交，其余 schedule 为本地运行态。
- [`teams/`](/Users/linlay/Project/zenmind/zenmind-env/teams)：团队配置。正式 yml、example 和 demo 都可提交。
- [`tools/`](/Users/linlay/Project/zenmind/zenmind-env/tools)：平台工具定义，作为正式配置提交。
- [`chats/`](/Users/linlay/Project/zenmind/zenmind-env/chats)：聊天记录与附件。仅 example 样例可提交。
- `owner/`：真实 owner 档案，只本地使用。
- [`owner.example/`](/Users/linlay/Project/zenmind/zenmind-env/owner.example)：owner 初始化模板。
- [`root/`](/Users/linlay/Project/zenmind/zenmind-env/root)：本地运行容器家目录，只保留 `.example` 模板。
- [`dist/`](/Users/linlay/Project/zenmind/zenmind-env/dist)：打包产物目录，不纳入 Git。

## 5. 数据结构

核心文件契约如下：

- `agents/<agent-id>/agent.yml`：智能体主定义，描述名称、角色、模型、技能、沙箱和模式
- `registries.example/{models,providers,mcp-servers,viewport-servers}/*.yml`：平台模板配置
- `registries/.../*.yml`：工作区当前生效的 live registry
- `schedules/*.example.yml`、`teams/*.yml`、`tools/*.yml`：平台运行配置模板与正式配置
- `chats/<chatId>.jsonl`：按行记录的会话事件流
- `owner.example/BOOTSTRAP.md`：owner 初始化模板说明
- `owner/OWNER.md`：真实 owner 主文档，仅本地维护

## 6. API 定义

本仓库没有业务 API、数据库 API 或服务接口定义。这里的“接口”是文件和目录契约：

- 文件名后缀决定配置语义，例如 `*.example`、`*.demo`
- 打包入口只识别命名规则，不接收自定义筛选参数
- Git 提交边界与打包边界不再完全一致：demo 可提交，但仍不进入打包产物；运行态仍不提交

## 7. 开发要点

- 修改平台事实时，优先修改 example 模板和正式配置，不把 live 运行态写成仓库事实
- `demo` 仅用于本地演示和实验，命名上必须清晰可识别
- 不在仓库中保存真实密钥、token、密码、个人画像或聊天历史
- `README.md` 负责人类使用与维护入口，`CLAUDE.md` 负责项目事实与目录契约
- 调整打包边界时，应同步检查 [`package.sh`](/Users/linlay/Project/zenmind/zenmind-env/package.sh) 和根级 `.gitignore`

## 8. 开发流程

推荐维护流程：

1. 在正式目录或 example 目录中完成配置修改
2. 确认命名符合 `example/demo/live` 约定
3. 运行 `./package.sh` 验证打包结果是否符合预期
4. 检查 Git 状态，确保未把运行态和私有数据纳入变更
5. 需要初始化本地用户态时，优先从 `owner.example/` 和 `registries.example/` 复制生成

## 9. 已知约束与注意事项

- `registries/` 是当前工作区 live 配置，不能替代 `registries.example/`
- `owner/` 和真实 `chats/` 包含用户态信息，默认不应入库
- `root/` 同时承载缓存、状态和本地配置，必须区分 `.example` 模板与真实运行态
- `tools/` 作为平台配置提交，并参与当前打包产物
- 空目录不会被 Git 跟踪；若某个 example 目录需要长期保留，应通过可提交文件显式承载
