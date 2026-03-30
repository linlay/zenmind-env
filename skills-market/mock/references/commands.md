# mock Commands

## Route Selection

- 只想产出一行 stdout：用 `mock echo`
- 只想产出一行 stderr：用 `mock stderr`
- 只想返回失败：用 `mock fail`
- 需要指定进程退出码：用 `mock exit`
- 需要合法 JSON：用 `mock json`
- 需要读取单个环境变量：用 `mock env`
- 需要把 stdin 原样吐回：用 `mock stdin`
- 需要固定数量的行：用 `mock lines`
- 需要延迟流式输出：用 `mock stream`
- 需要创建或检查 `.config` / `.local`：不要硬读文件，改走 `mock xdg`

## Canonical Commands

```bash
mock version
mock sleep 20ms
mock echo hello world
mock stderr warning message
mock exit 7
mock fail broken state
mock json '{"ok":true}'
mock args one two three
mock env HOME
printf 'demo\n' | mock stdin
mock lines 3
mock stream 3 --interval 100ms
mock stream 3 hello world done --interval 100ms
```

## Behavior Notes

- `fail` 走退出码 `1`
- 参数或命令用法错误走退出码 `2`
- `env` 在变量不存在时失败
- `stream` 传自定义内容时，内容条目数必须等于 `count`
- `sleep` 和 `stream --interval` 使用 Go duration 语法

## Help Policy

- 优先用 `mock help`
- 子命令说明优先用 `mock <subcommand> --help`
- 需要稳定文本断言时，直接使用 help 输出，不要自己重写说明
