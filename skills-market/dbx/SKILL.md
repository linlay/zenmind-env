---
name: "dbx"
description: "Use this skill when the user wants to use dbx to connect to MySQL, PostgreSQL, or SQLite; discover command usage from built-in help; inspect connections, schemas, or tables; run query/update/schema/admin/import/export/tx commands; or troubleshoot dbx safety and policy errors without treating config/local files as the default interface."
---

# dbx

先读这个 skill，再操作 `dbx`。

把 `dbx` 当成 help-driven CLI，不要把 `~/.config/dbx`、SQLite 本地文件、raw config 当成默认入口。

正常路径先走内置 help 和显式子命令。只有当 help、命令输出和错误还不足以解释问题时，才允许把读取 config 或 local/raw file 当成最后兜底排障。

## What It Covers

- help 驱动 discovery：`dbx --help`、`dbx <command> --help`
- 连接管理：`conn list` / `conn show` / `conn test`
- 结构查看：`inspect schema` / `inspect table` / `inspect connection`
- 显式 SQL 动作：`query` / `update` / `schema` / `admin`
- 文件导入导出：`import` / `export`
- 多步原子动作：`tx`
- 配置与排障：`allow_actions`、secret 来源、SQLite 路径、分页、`--dry-run`

## Core Rules

- 先 discovery，后 execution
- 先 `--help`，再跑具体命令
- 先 `conn` / `inspect`，再执行 SQL、导入导出或事务
- 不要默认读取：
  - `~/.config/dbx/*.toml`
  - SQLite 本地库文件
  - 用户口中的 `config`、`local`、raw file
- 需要切换配置来源时，优先补 `--config <path>` 重跑内置命令
- 只有排障时，才允许少量、定点读取具体 config 或 local/raw file

## Default Workflow

默认按这个顺序推进，不要跳到 config 或 raw file：

1. 先读这个 skill，确认不要先翻 config/local
2. 执行 `dbx --help`
3. 执行 `dbx conn --help`
4. 执行 `dbx inspect --help`
5. 针对目标动作执行 `dbx query --help`、`dbx update --help`、`dbx schema --help` 或 `dbx admin --help`
6. 需要事务、导入或导出时，再看 `dbx tx --help`、`dbx import --help`、`dbx export --help`
7. 真正执行前，先用 `dbx conn test <name>`、`dbx conn show <name>`、`dbx inspect table <conn> <table>`、`dbx inspect connection <conn>` 收集当前事实
8. 只有当 help、命令输出和错误 payload 还不足以解释问题时，才去看 config、SQLite 路径或其他 local/raw file

## Routing

- 问“这个命令怎么用”“支持哪些入口和 flag”“应该先看哪个 help”：先读 `references/commands.md`
- 问“为什么被拦截”“为什么报错”“cursor 为什么不对”“事务 plan 为什么不行”：先读 `references/safety-and-troubleshooting.md`
- 问“输出长什么样”“分页怎么继续”“`verbose` / `dry-run` 会返回什么”：再读 `references/output-and-behavior.md`
- 问“连接文件怎么配”“secret 怎么写”“SQLite 路径为什么不对”：只在 setup 或 troubleshooting 时读 `references/configuration.md`

## Global Rules

1. 优先讲当前稳定入口：`conn`、`inspect`、`query/update/schema/admin`、`import/export`、`tx`、`version`；不要发明 `exec`、`describe` 之类不存在的独立命令。
2. 默认优先引用 `dbx --help` 和 `dbx <command> --help`。`dbx help ...` 只作为兼容写法补充，不作为首选入口。
3. 表结构问题优先用 `inspect`，不要把 SQL `describe` 当成官方命令面的一部分来讲。
4. 当前稳定权限边界是 `allow_actions`，不是 `mode`。只有遇到旧配置、旧报错或旧文档时，才把 `mode` 当成迁移背景来解释。
5. 事务相关问题统一按 `dbx tx <conn> --plan <path.json>` 来讲，且只允许 `query` / `update` step。
6. SQLite 相对 `path` 是相对于配置文件目录，不是当前 shell 目录。
7. `--config` 是配置来源 override flag，不是默认信息入口。只有需要切换环境、复现实例或排障时，才把它放到前台。

## File Reading Policy

- 正常使用时，不读取 `~/.config/dbx/*.toml`
- 正常使用时，不把 SQLite 本地文件或其他 local/raw file 当成默认入口
- 优先使用 `dbx --help`、`dbx <command> --help`、`conn`、`inspect`、`query/update/schema/admin`、`tx`、`import/export`
- 需要切换配置目录或单文件时，优先使用 `--config <path>` 重跑 help 或相关命令
- 只有当内置 help、命令输出和错误 payload 已经不足以解释问题时，才允许读取具体 config 文件
- 只有当 SQLite 路径、secret 解析或环境差异问题已经被 CLI 输出阻塞时，才允许读取少量 local/raw file
- 即使进入兜底排障，也只做针对性的少量读取，不把扫目录或通读配置当成默认流程

## References

- `references/commands.md`
- `references/safety-and-troubleshooting.md`
- `references/output-and-behavior.md`
- `references/configuration.md`
