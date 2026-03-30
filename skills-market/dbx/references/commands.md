# Commands

## Help-First Command Discovery

默认先看 CLI 自己的帮助面，不要先去翻 config 或 raw file。

推荐顺序：

```bash
dbx --help
dbx conn --help
dbx inspect --help
dbx query --help
dbx update --help
dbx schema --help
dbx admin --help
dbx tx --help
dbx import --help
dbx export --help
```

使用规则：

- `dbx <command> --help` 是默认入口
- `dbx help <topic>` 只作为兼容补充，不作为首选入口
- `--config <path>` 是 override flag，用来切换配置来源，不是默认 discovery 起点
- `conn` / `inspect` 是标准前置步骤；SQL、导入导出、事务命令属于执行阶段

## Command Surface

`dbx` 当前稳定命令面：

- `conn`
- `inspect`
- `query`
- `update`
- `schema`
- `admin`
- `import`
- `export`
- `tx`
- `version`

优先按显式动作来讲，不要把旧的泛化执行入口当成当前能力。

## Connection Commands

用来确认连接是否存在、最终会连到哪里、以及目标是否可达。

先看：

```bash
dbx conn --help
```

```bash
dbx conn list
dbx conn show local-pg
dbx conn test local-pg
```

要点：

- `list` 返回连接名、engine、`allow_actions`、tags
- `show` 返回解析后的连接信息和脱敏后的目标信息
- `test` 先于 `inspect` / `query`
- 正常流程先用 `conn` 确认目标是否真实存在，再考虑是否需要 `--config`

## Inspect

`inspect` 是结构查看入口。

先看：

```bash
dbx inspect --help
```

```bash
dbx inspect schema local-pg
dbx inspect table local-pg users
dbx inspect connection local-pg
```

要点：

- `inspect schema <conn> [schema]`
- `inspect table <conn> <table> [schema]`
- `inspect connection <conn>`
- 表结构、主键、唯一键、外键优先走这里，不要先猜表形状

## SQL Action Commands

四个显式 SQL 动作：

- `query`：只读 SQL
- `update`：DML，如 `insert / update / delete / merge`
- `schema`：DDL，如 `create / alter / drop / truncate / rename`
- `admin`：管理类 SQL，如 `grant / revoke / vacuum / analyze / set`

执行前先看对应帮助：

```bash
dbx query --help
dbx update --help
dbx schema --help
dbx admin --help
```

输入形式：

```bash
dbx query local-pg 'select * from users'
dbx query file local-pg ./query.sql
dbx query dsn postgres 'postgres://app:secret@127.0.0.1:5432/appdb?sslmode=disable' 'select now()'
```

同样适用于 `update` / `schema` / `admin`。

关键 flag：

- `--config <path>`：读取指定配置目录或文件，用于 override 当前配置来源
- `--format json|table`
- `--page-size <n>`：查询分页大小，默认 `100`
- `--cursor <n>`：继续读取上一页
- `--dry-run`：只做策略校验，不执行 SQL
- `--max-rows-affected <n>`：写入安全上限，默认 `1000`
- `--verbose`：补充 engine、连接元信息等

使用规则：

- 先 `conn test` / `conn show` / `inspect`，再执行 SQL
- `query` / `update` / `schema` / `admin` 会先做 SQL 分类，再校验和命令动作是否匹配
- 多语句默认阻断
- `update` / `delete` 缺少 `WHERE` 会被拦截
- 继续分页时要保持同一条 SQL，尤其要保留相同的 `order by`

## Import / Export

执行前先看：

```bash
dbx import --help
dbx export --help
```

导入：

```bash
dbx import file ./users.csv local-sqlite users
dbx import file ./users.json local-sqlite users --dry-run
```

导出：

```bash
dbx export table users local-sqlite ./users.csv --format csv
dbx export table users local-sqlite ./users.json --format json --limit 500
```

要点：

- `import` 当前入口是 `import file <path> <conn> <table>`
- `import` 走 `update` 权限边界，`--dry-run` 会先校验数据和策略
- `export` 当前入口是 `export table <table> <conn> <out>`
- `export` 本质上使用 `query` 权限
- `export` 支持 `--format csv|json` 和 `--limit <n>`

## Tx

`tx` 用于单连接、单次调用、单事务的结构化事务计划。

执行前先看：

```bash
dbx tx --help
```

```json
{
  "steps": [
    {"action": "query", "sql": "select id from users where id = 1"},
    {"action": "update", "sql": "update users set active = 1 where id = 1", "max_rows_affected": 1}
  ]
}
```

```bash
dbx tx local-pg --plan ./plan.json
dbx tx local-pg --plan ./plan.json --dry-run
```

要点：

- 最小形式是 `dbx tx <conn> --plan <path.json>`
- 每个 step 必须有 `action` 和 `sql`
- 只支持 `query` 和 `update`
- 不支持 `schema` / `admin`
- 任一步失败，整笔事务回滚

## Legacy Note

如果看到旧 help、旧二进制或旧示例仍在提 `--mode` / `mode`：

- 把它当成过时材料
- 当前 skill 统一按 `allow_actions` 和当前源码语义来讲
- 配置里出现 `mode` 时，应迁移到 `allow_actions = [...]`
