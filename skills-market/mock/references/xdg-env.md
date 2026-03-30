# mock XDG Environment

## What It Is

`mock xdg` 用来在一个显式 root 下创建和检查 mock `.config` / `.local` 环境树。

这条能力适合：

- 给别的 CLI 准备可直接使用的本地配置目录
- 测试脚本如何读取 `~/.config/...` 或 `~/.local/...`
- 快速确认 mock 环境树里有哪些文件、权限和内容

## Canonical Commands

```bash
mock xdg apply --root /tmp/mock-home --manifest ./manifest.json
mock xdg apply --root /tmp/mock-home --manifest - --overwrite
mock xdg inspect --root /tmp/mock-home
mock xdg inspect --root /tmp/mock-home --reveal
```

## Default Workflow

1. 如果环境树已经存在，先执行 `mock xdg inspect --root <dir>`
2. 如果缺目录、缺文件或需要更新，再执行 `mock xdg apply`
3. 只有需要看具体文本或 JSON 内容时，才执行 `mock xdg inspect --root <dir> --reveal`
4. 不要默认先手工读取 `.config/**` 或 `.local/**` 的原始文件

## Manifest Rules

- v1 只支持 JSON manifest
- 顶层字段：`entries`
- 每个 entry 支持：
  - `path`
  - `type`
  - `format`
  - `content`
  - `mode`

约束：

- `path` 必须是相对路径
- `path` 必须以 `.config/` 或 `.local/` 开头
- 不能使用绝对路径
- 不能使用 `..` 逃逸 root
- `type=dir` 不能带 `content`
- `type=file` 必须带 `content`
- `format=json` 会写成规范 JSON 文本

## Root And Exports

`apply` 的文本输出会给出推荐导出值：

- `HOME=<root>`
- `XDG_CONFIG_HOME=<root>/.config`
- `XDG_DATA_HOME=<root>/.local/share`
- `XDG_STATE_HOME=<root>/.local/state`

如果目标脚本或 CLI 需要 XDG 环境，优先复用这些导出值，而不是手写别的目录约定。

## Reveal Policy

- 默认 `inspect` 只返回 metadata
- `--reveal` 只会返回 UTF-8 文本或合法 JSON 文件内容
- 二进制文件仍应只看 metadata，不要假设它们会被内联展示
