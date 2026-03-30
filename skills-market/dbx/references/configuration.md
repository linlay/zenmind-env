# Configuration

这份文档不是 `dbx` 的默认入口。

正常使用时，先看：

```bash
dbx --help
dbx conn --help
dbx inspect --help
dbx query --help
```

只有下面场景才优先读这里：

- 第一次创建连接 profile
- 需要解释 `--config <path>` 指向哪个目录或文件
- 排查 secret、SQLite 路径、旧字段迁移等配置问题
- 内置 help、命令输出和错误 payload 已经不足以解释问题

## Config Layout

`dbx` 默认从 `~/.config/dbx` 读取连接配置。

当前格式是每个连接一个文件：

```text
~/.config/dbx/<name>.toml
```

连接名就是文件名去掉 `.toml` 之后的部分。每个文件必须有一个 `[connection]` table。

```toml
[connection]
engine = "postgres"
dsn_env = "LOCAL_PG_DSN"
allow_actions = ["query"]
tags = ["dev"]
```

关键点：

- `connection.allow_actions` 是必填
- `mode` 已移除
- 旧的 multi-connection 格式已移除
- `--config` 可以指向配置目录，也可以指向单个 `.toml` 文件
- `--config` 是 override flag，不是默认 discovery 起点

## PostgreSQL Example

```toml
[connection]
engine = "postgres"
dsn_env = "LOCAL_PG_DSN"
allow_actions = ["query"]
tags = ["dev"]
```

## MySQL Example

```toml
[connection]
engine = "mysql"
host = "127.0.0.1"
port = 3306
user = "app"
database = "appdb"
password.env = "MYSQL_PASSWORD"
allow_actions = ["query"]
```

## SQLite Example

```toml
[connection]
engine = "sqlite"
path = "./demo.db"
allow_actions = ["query"]
tags = ["local"]
```

注意：SQLite 的相对 `path` 是相对于配置文件目录，不是当前命令执行目录。

## Supported Fields

常见字段：

- `engine`
- `dsn`
- `dsn_env`
- `host`
- `port`
- `user`
- `password`
- `database`
- `schema`
- `path`
- `sslmode`
- `readonly`
- `timeout`
- `role`
- `tags`
- `allow_actions`

支持的 engine：

- `postgres` / `postgresql`
- `mysql`
- `sqlite` / `sqlite3`

## Secret Sources

密码或 DSN 可以来自：

- `password.env`
- `password.file`
- `password.cmd`
- 明文值
- `dsn_env`

示例：

```toml
[connection]
engine = "mysql"
host = "127.0.0.1"
user = "app"
database = "appdb"
password.env = "MYSQL_PASSWORD"
allow_actions = ["query"]
```

规则：

- `password.cmd` 必须是 argv 数组，不是 shell 字符串
- `password.file` 和 SQLite 相对 `path` 会按配置文件所在目录归一化
- PostgreSQL 常见做法是 `dsn_env`

## Allow Actions

当前稳定权限边界是 `allow_actions`。

可选动作：

- `query`
- `update`
- `schema`
- `admin`

示例：

```toml
[connection]
engine = "sqlite"
path = "./demo.db"
allow_actions = ["query", "update", "schema"]
```

规则：

- `allow_actions` 只收紧 DBX 侧能力边界，不会放大数据库账号权限
- prod-like 连接会额外阻止包含 `schema` 或 `admin` 的配置
- `dsn` 入口是临时连接，不替代 profile 配置

## When To Read Config Files

排障时建议按这个顺序，不要一上来先翻文件：

1. 先重看相关 `dbx <command> --help`
2. 再跑 `dbx conn test <name>`、`dbx conn show <name>`、`dbx inspect connection <name>`
3. 需要切换配置来源时，优先补 `--config <path>` 重跑命令
4. 只有当 CLI 输出仍然不足以解释问题时，才读取具体 config 文件

适合读配置文件的典型问题：

- 连接名和文件名是否一致
- `allow_actions` 是否配置正确
- `dsn_env`、`password.env`、`password.file`、`password.cmd` 是否写对
- SQLite `path` 是否按配置文件目录解析

## Legacy And Migration

遇到旧材料时按下面解释：

- 旧格式 `default_connection` / `connections`：已废弃，迁移到 `~/.config/dbx/<name>.toml` 单文件格式
- 旧字段 `mode`：已废弃，迁移到 `allow_actions = [...]`
- 如果配置里还写了 `mode`，当前实现会直接报错，而不是自动转换
