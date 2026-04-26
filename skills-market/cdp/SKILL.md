---
name: "cdp"
description: "Use this skill when the user wants to control a Chrome browser via Chrome DevTools Protocol (CDP): launch Chrome with remote debugging, list/manage tabs, navigate to URLs, execute JavaScript, take screenshots, query/interact with DOM, or wait for page loads."
---

# cdp

先读这个 skill，再操作 CDP。

`cdp` 是 skill 名，不是可执行命令。没有 `cdp` CLI，不要执行 `cdp --help`、`which cdp`，不要尝试安装 `cdp` 命令，也不要把 macOS `open` 当作 CDP 自动化成功路径。

CDP 分两层使用：

- HTTP 层：用 `curl` 做 target discovery，比如检查版本、列 tabs、新建或激活 tab。
- WebSocket 层：用内置 Node helper 做页面操作，比如导航、执行 JS、截图、DOM 查询和输入事件。

默认环境变量来自 `.sandbox-env.json`：

- `CDP_HOST=localhost`
- `CDP_PORT=9222`

固定 helper 路径：

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
```

## Core Rules

- 先检查 CDP 是否可达，再做任何页面操作。
- 先列 tabs，再选择目标 tab。
- 不存在 `cdp` 命令；所有 discovery 用 `curl`，所有页面 CDP command 用 `node "$CDP_HELPER"`。
- 不用 `open <url>` 作为 CDP 自动化的完成证明；`open` 只能打开页面，不能证明 CDP 控制链路。
- 不关闭用户已有 tab；除非用户明确要求，不调用 `/json/close`。
- 导航前确认目标 tab，避免改错用户页面。
- 截图和 JS 结果要明确展示；截图保存到用户可识别的显式路径。
- 页面可能包含敏感信息，执行 JS、截图或输出 DOM 前先控制输出范围。

## Default Workflow

默认按这个顺序推进，不要跳步：

1. 先读这个 skill。
2. 用 `curl "http://$CDP_HOST:$CDP_PORT/json/version"` 检查 CDP 连通性。
3. 不可达时，引导用户完全退出 Chrome 后用 remote debugging 参数重新启动。
4. 用 `curl "http://$CDP_HOST:$CDP_PORT/json"` 列出 tabs。
5. 新建或选择目标 tab，并记录它的 `webSocketDebuggerUrl`。
6. 用 `node "$CDP_HELPER" "$WS" <method> '<params-json>'` 执行页面操作。
7. 验证操作结果，例如读取 `document.title`、URL、DOM 状态或截图。
8. 需要视觉证明时，用 `Page.captureScreenshot` 保存截图。

## Step-By-Step Command Use

### Step 1: Check CDP

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
```

成功时重点看：

- `Browser`
- `Protocol-Version`
- `webSocketDebuggerUrl`

### Step 2: Launch Chrome With CDP

如果 CDP 不可达，macOS 上先完全退出 Chrome，再启动独立 profile：

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port="$CDP_PORT" \
  --user-data-dir=/tmp/chrome-cdp-test
```

如果已有 Chrome 进程没有带 remote debugging 参数，直接运行上面的命令通常不会生效，必须先完全退出已有 Chrome。

### Step 3: List Tabs

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json"
```

重点看：

- `id`
- `type`
- `title`
- `url`
- `webSocketDebuggerUrl`

只选择 `type` 为 `page` 的 target。

### Step 4: New Or Activate A Tab

新建 tab：

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/new?https://example.com"
```

激活 tab：

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/activate/<target-id>"
```

记录响应里的 `webSocketDebuggerUrl`：

```bash
WS='ws://localhost:9222/devtools/page/<target-id>'
```

### Step 5: Navigate

```bash
node "$CDP_HELPER" \
  "$WS" \
  Page.navigate \
  '{"url":"https://example.com"}'
```

等待 load event：

```bash
node "$CDP_HELPER" \
  "$WS" \
  Page.navigate \
  '{"url":"https://example.com"}' \
  --wait-event Page.loadEventFired \
  --timeout 15000
```

### Step 6: Execute JavaScript

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"document.title","returnByValue":true}'
```

异步表达式：

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"fetch(location.href).then(r => r.status)","awaitPromise":true,"returnByValue":true}'
```

### Step 7: Screenshot

```bash
node "$CDP_HELPER" \
  "$WS" \
  Page.captureScreenshot \
  '{"format":"png","captureBeyondViewport":true}' \
  --save /tmp/cdp-screenshot.png \
  --timeout 20000
```

### Step 8: Query DOM

用 JS 查询更适合 bash 场景：

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"document.querySelector(\"h1\")?.innerText ?? null","returnByValue":true}'
```

使用 DOM domain：

```bash
node "$CDP_HELPER" \
  "$WS" \
  DOM.getDocument \
  '{"depth":1}'
```

### Step 9: Click Element

优先用页面 JS 触发普通点击：

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"document.querySelector(\"button\")?.click()","returnByValue":true}'
```

需要真实鼠标事件时，先算元素中心点，再发 mouse events：

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"(() => { const r = document.querySelector(\"button\").getBoundingClientRect(); return {x:r.left+r.width/2,y:r.top+r.height/2}; })()","returnByValue":true}'
```

```bash
node "$CDP_HELPER" \
  "$WS" \
  Input.dispatchMouseEvent \
  '{"type":"mousePressed","x":100,"y":100,"button":"left","clickCount":1}'
node "$CDP_HELPER" \
  "$WS" \
  Input.dispatchMouseEvent \
  '{"type":"mouseReleased","x":100,"y":100,"button":"left","clickCount":1}'
```

### Step 10: Type Text

```bash
node "$CDP_HELPER" \
  "$WS" \
  Runtime.evaluate \
  '{"expression":"document.querySelector(\"input\")?.focus()","returnByValue":true}'
node "$CDP_HELPER" \
  "$WS" \
  Input.insertText \
  '{"text":"hello from CDP"}'
```

### Recipe: 打开浏览器并切换到百度

这个请求必须走 CDP 控制链路，不要用 `cdp --help`，也不要用 `open "https://www.baidu.com"` 作为完成结果。

1. 定义 helper 并检查 CDP：

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
```

2. 如果不可达，提示用户完全退出 Chrome 后启动：

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port="$CDP_PORT" \
  --user-data-dir=/tmp/chrome-cdp-test
```

3. 列出 tabs，并选择 `type` 为 `page` 的 target：

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json"
```

4. 没有合适 tab 时新建百度 tab：

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/new?https://www.baidu.com/"
```

5. 使用返回的 `webSocketDebuggerUrl` 导航并等待加载：

```bash
WS='<webSocketDebuggerUrl>'
node "$CDP_HELPER" "$WS" Page.navigate \
  '{"url":"https://www.baidu.com/"}' \
  --wait-event Page.loadEventFired \
  --timeout 15000
```

6. 验证当前页面：

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"({url:location.href,title:document.title,readyState:document.readyState})","returnByValue":true}'
```

## Helper Script Usage

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
node "$CDP_HELPER" \
  <ws-url> <method> [params-json] [options]
```

Options:

- `--wait-event <event>` waits for one CDP event, for example `Page.loadEventFired`.
- `--save <file>` decodes `result.data` as base64 and saves it.
- `--timeout <ms>` controls the total wait time.

The helper opens one WebSocket connection, sends the requested command, waits for the matching response and optional event, prints JSON, and exits. It does not keep state between calls.

When `--wait-event` is set, the helper enables that event's CDP domain in the same WebSocket session before sending the main command. For example, `--wait-event Page.loadEventFired` sends `Page.enable` first, then sends the requested command.

## Safety Rules

- 不关闭非自己创建的 tab。
- 导航前确认当前选中的 tab `id`、`title` 和 `url`。
- 截图文件保存到明确路径，例如 `/tmp/cdp-screenshot.png`。
- 不把整页 HTML、cookies、tokens、localStorage 或包含敏感信息的截图直接长篇输出。
- 如果用户要求操作现有登录页面，先说明将会读取或截图当前页面状态。

## File Reading Policy

- 正常使用 CDP 不需要读取本地浏览器 profile 或 Chrome 配置文件。
- 所有浏览器状态优先通过 HTTP endpoint 和 WebSocket CDP 命令获取。
- 只有排查 helper 脚本自身问题时，才读取 `/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs`。

## References

- `references/commands.md`
- `references/troubleshooting.md`
