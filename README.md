# ZenMind 配置工作区

## 1. 项目简介

这是 ZenMind 智能体平台的配置与运行时工作区，不是传统应用开发仓库。仓库里同时承载：

- 平台正式配置，例如 `agents/`、`tools/`、共享 `skills-market/`
- 可发布模板，例如 `registries.example/`、`owner.example/`
- 本地运行态数据，例如 `chats/`、`owner/`、`root/` 下的真实配置和缓存

工作区的核心约定是：

- `example` 用于提交、初始化和打包
- `demo` 用于本地演示，不纳入 Git，也不进入发布包
- live 运行态目录只在本地使用，不作为仓库事实源

## 2. 快速开始

### 前置要求

- Bash 环境
- `cp`、`find`、`mkdir`、`mktemp`、`tar` 等基础命令可用

### 初始化本地工作区

按模板生成本地运行态目录：

```bash
cp -R registries.example registries
cp -R owner.example owner
```

然后按需补充本地运行态内容：

- 在 `registries/` 中维护当前工作区生效的 models/providers/mcp-servers/viewport-servers
- 在 `owner/` 中完成真实 owner 档案初始化
- 在 `root/` 下写入本地容器家目录配置，不把真实密钥和状态文件提交到 Git

### 如何配置 owner/

`owner/` 是当前工作区的真实 owner 目录，只在本地使用，不提交到 Git。

建议步骤：

1. 先从模板复制生成本地目录：

```bash
cp -R owner.example owner
```

2. 再按 [`owner.example/BOOTSTRAP.md`](/Users/linlay/Project/zenmind/zenmind-env/owner.example/BOOTSTRAP.md) 的说明完成初始化。
3. 把真实身份、偏好、私有资料、密钥和一次性运行状态都保留在 `owner/` 中，不要回写到 `owner.example/`。

### 如何配置 root/

`root/` 是本地容器家目录，用来承载运行时配置、缓存和工具状态，不是仓库事实源。

使用约定：

- 只把 `.example` 模板纳入 Git，例如 `root/.zenmind-config.example`、`root/.config.example/`
- 真实 `.config/`、`.cache/`、`.local/`、`.nuget/`、`.npm/`、`.dotnet/` 等目录都视为本地运行态
- 新增模板时，优先使用 `.example` 命名，并与 `.gitignore` 规则保持一致
- 真实本地配置和缓存只留在 `root/` 下，不要把运行态文件提交到仓库

### 打包发布

当前仓库自带 [`package.sh`](/Users/linlay/Project/zenmind/zenmind-env/package.sh)，会按固定命名规则生成可发布归档：

```bash
./package.sh
```

输出目录为 [`dist/`](/Users/linlay/Project/zenmind/zenmind-env/dist)。该脚本不接受自定义筛选参数，只按工作区命名约定打包。

## 3. 配置说明

### 目录角色

- [`agents/`](/Users/linlay/Project/zenmind/zenmind-env/agents)：智能体定义。正式 agent 可提交，`*.demo` 仅本地使用。
- [`registries.example/`](/Users/linlay/Project/zenmind/zenmind-env/registries.example)：registry 模板与打包来源，提交到 Git。
- `registries/`：当前工作区 live registry，本地维护，不提交。
- [`skills-market/`](/Users/linlay/Project/zenmind/zenmind-env/skills-market)：共享技能市场。正式 skill 提交，demo/临时内容本地化。
- [`schedules/`](/Users/linlay/Project/zenmind/zenmind-env/schedules)：计划任务定义。正式 yml 和 `*.example.yml` 可提交，`*.demo.yml` 忽略。
- [`teams/`](/Users/linlay/Project/zenmind/zenmind-env/teams)：团队配置。正式 yml 和 `*.example.yml` 可提交，`*.demo.yml` 忽略。
- [`tools/`](/Users/linlay/Project/zenmind/zenmind-env/tools)：平台工具定义，作为正式配置提交。
- [`chats/`](/Users/linlay/Project/zenmind/zenmind-env/chats)：会话历史与附件。只保留 `*.example.jsonl` 和 `*.example/` 样例，其余为运行态。
- [`owner.example/`](/Users/linlay/Project/zenmind/zenmind-env/owner.example)：owner 初始化模板，提交并参与打包。
- `owner/`：真实 owner 档案，只本地使用。
- [`root/`](/Users/linlay/Project/zenmind/zenmind-env/root)：本地运行容器家目录。只保留 `.example` 模板，真实 `.config`、缓存和状态文件不提交。

### 如何维护 owner/ 与 root/

#### owner/

- `owner/` 是真实本地目录，不提交。
- 初始化时从 [`owner.example/`](/Users/linlay/Project/zenmind/zenmind-env/owner.example) 复制生成。
- 模板入口以 [`owner.example/BOOTSTRAP.md`](/Users/linlay/Project/zenmind/zenmind-env/owner.example/BOOTSTRAP.md) 为准。
- 真实身份、偏好、私有资料、密钥和一次性状态都应只留在 `owner/`。

#### root/

- `root/` 是本地运行容器家目录，不作为共享配置事实源。
- 只允许 `.example` 模板进入 Git，例如 `root/.zenmind-config.example`、`root/.config.example/`。
- 真实 `.config/`、`.cache/`、`.local/`、`.nuget/`、`.npm/`、`.dotnet/` 等都属于运行态。
- 新增模板时，优先使用 `.example` 命名，并与 `.gitignore` 规则保持一致。

### Git 与打包规则

- Git 以模板和正式配置为主，不以本地运行态为主
- 打包时：
  - `registries.example/` 会写入归档中的 `registries/`
  - `owner.example/` 会写入归档中的 `owner/`
  - `chats/` 只会带上 example 样例
  - `tools/` 不进入发布包
- `demo` 和真实用户态数据不会成为发布物的一部分

## 4. 部署

这个仓库本身不提供业务服务部署入口，它提供的是 ZenMind 工作区数据包和配置素材。

常见交付方式是：

1. 在当前仓库维护正式配置与 example 模板
2. 运行 `./package.sh` 生成归档
3. 将归档交给上层运行时或发布链路加载

如果需要宿主应用或平台主仓的发布流程，应在对应主仓中完成镜像构建、挂载和上线，而不是在这个工作区里维护业务部署脚本。

## 5. 运维与维护

### 日常维护建议

- 新增 agent 时，优先区分正式配置和 demo 试验目录
- 调整 registry 时，先改 `registries.example/` 模板，再决定本地 live `registries/` 是否同步
- 新增 schedule、team 时，正式配置用正常文件名，演示内容用 `*.demo.yml`
- 调整共享 skill 时，优先保证 `SKILL.md`、`references/`、`scripts/` 职责清晰

### 常见排查

- 打包结果不符合预期时，先查看 [`package.sh`](/Users/linlay/Project/zenmind/zenmind-env/package.sh) 中的命名规则
- 某个配置没有入包时，先检查它是否被命名为 `*.demo`
- 某个本地文件出现在 `git status` 中时，先确认它是否应当归类为 live 运行态
- 如果需要初始化 owner，优先从 [`owner.example/BOOTSTRAP.md`](/Users/linlay/Project/zenmind/zenmind-env/owner.example/BOOTSTRAP.md) 开始
