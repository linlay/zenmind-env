# Safety And Troubleshooting

默认不要一上来就读 config 或 local/raw file。

先用 `dbx` 自己的帮助和内置命令收集事实，只有当这些信息还不足以解释问题时，才去读配置文件、SQLite 路径或其他 local/raw file。

## Safety Boundaries

`dbx` 不是任意 SQL 壳，它会先做自己的策略校验。

核心边界：
- 默认只允许单语句
- `allow_actions` 是 DBX 层白名单
- SQL 类型要和命令动作匹配
- 危险写入缺少 `WHERE` 会被拦截
- `tx` 只允许 `query/update`
- `tx` 不支持 `schema/admin`
- prod-like 连接默认阻止 `schema/admin`

## Common Problems

### Connection Not Found

现象：连接名不存在。

先检查：
- 先看 `dbx conn --help`
- 跑 `dbx conn list`
- 跑 `dbx conn show <name>`
- 确认是否补错了 `--config`

如果以上还不足以解释，再检查：
- 文件是不是 `~/.config/dbx/<name>.toml`
- 传入的连接名是否等于文件名

### Action Blocked

现象：`action_blocked`

先检查：
- 先看对应的 `dbx query|update|schema|admin --help`
- 跑 `dbx conn show <name>`
- 当前连接的 `allow_actions`
- 你是不是拿 `query` 去跑写 SQL，或者反过来
- 该连接是不是 prod-like，并且配置了 `schema/admin`

### Action Mismatch

现象：`action_mismatch`

先检查：
- 先看对应的 `dbx query|update|schema|admin --help`
- `query` 是否真的在跑只读 SQL
- `update` 是否真的在跑 DML
- `schema` 是否真的在跑 DDL
- `admin` 是否真的在跑管理类 SQL

### Missing WHERE

现象：危险写入被拦截。

先检查：
- 先看 `dbx update --help`
- `update` / `delete` 是否缺少 `WHERE`
- 条件是否足够收窄

### Multiple Statements Blocked

现象：`multiple_statements_blocked`

先检查：

- 先看对应动作的 `--help`
- 一次是不是传入了多条 SQL
- SQL 文件里是不是包含了多个语句
- 是否误把复制来的注释或尾部分号之外内容一起带进去了

### Invalid Cursor

现象：`invalid_cursor`

先检查：

- 先看 `dbx query --help`
- `--cursor` 是否是非负整数
- 是否沿用了上一页返回的 `next_cursor`
- 是否还在用同一条 SQL，尤其保留了相同的 `order by`

### Secret Not Resolved

现象：密码或 DSN 没有读到。

先检查：
- 先跑 `dbx conn show <name>`
- `password.env` 对应环境变量是否存在
- `password.file` 路径是否可读
- `password.cmd` 是否写成 argv 数组
- `dsn_env` 是否已导出

### SQLite Path Wrong

现象：SQLite 查不到库。

先检查：
- 先跑 `dbx conn show <name>` 或 `dbx inspect connection <name>`
- `path` 是否是你想要的文件
- 相对路径是否按配置文件目录理解
- 绝对路径是否更适合当前场景

### Tx Plan Invalid

现象：`tx` 报缺少 `--plan`、step 非法，或 `tx_unsupported_action`。

先检查：
- 先看 `dbx tx --help`
- 调用形式是否是 `dbx tx <conn> --plan ./plan.json`
- plan 是否包含 `steps`
- 每个 step 是否都有 `action` 和 `sql`
- action 是否只使用 `query` 或 `update`
- step 内 SQL 是否仍然满足单语句、动作匹配和危险写入校验

## Recommended Troubleshooting Flow

1. 先重看相关 `dbx <command> --help`
2. 再跑 `dbx conn test <name>`、`dbx conn show <name>`、`dbx inspect connection <name>`、`dbx inspect table <conn> <table>`
3. 再检查错误 payload、命令参数和当前执行形态
4. 需要切换环境时，优先补 `--config <path>` 重跑内置命令
5. 只有当上面这些仍然不足以解释问题时，才读取 config、SQLite 路径或其他 local/raw file

## Legacy Note

如果错误来自旧配置里的 `mode`：

- 按迁移问题处理，不要继续推荐 `mode`
- 直接改成 `allow_actions = [...]`
- 如果看到旧帮助文字和当前源码不一致，以当前源码和当前 skill 为准
