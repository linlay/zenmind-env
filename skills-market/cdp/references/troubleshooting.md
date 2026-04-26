# CDP Troubleshooting

## `bash: cdp: command not found`

This is expected. `cdp` is the skill name, not a CLI executable.

Do not install a `cdp` command and do not treat this as skill failure. Use the actual command surface:

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"document.title","returnByValue":true}'
```

## `open` Worked But CDP Was Not Verified

macOS `open "https://www.baidu.com"` only asks the OS/browser to open a URL. It does not prove Chrome is running with CDP, does not identify a target, and does not verify WebSocket control.

After any accidental `open` fallback, continue with CDP verification:

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
curl -s "http://$CDP_HOST:$CDP_PORT/json"
node "$CDP_HELPER" "$WS" Page.navigate \
  '{"url":"https://www.baidu.com/"}' \
  --wait-event Page.loadEventFired \
  --timeout 15000
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"({url:location.href,title:document.title,readyState:document.readyState})","returnByValue":true}'
```

## Chrome Is Not Running Or Port Is Unreachable

Symptom:

- `curl "http://$CDP_HOST:$CDP_PORT/json/version"` fails
- connection refused
- empty response

Check the port:

```bash
lsof -i :"$CDP_PORT"
```

Start Chrome on macOS:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port="$CDP_PORT" \
  --user-data-dir=/tmp/chrome-cdp-test
```

## Chrome Is Running But CDP Is Missing

Chrome on macOS reuses the existing app process. If Chrome was already open without `--remote-debugging-port`, starting it again with the flag may not enable CDP.

Fix:

1. Fully quit Chrome.
2. Confirm no old Chrome process is bound to the intended profile.
3. Start Chrome with `--remote-debugging-port` and a separate `--user-data-dir`.
4. Retry `/json/version`.

## WebSocket Connection Failed

Common causes:

- The tab was closed.
- The `webSocketDebuggerUrl` is stale.
- The target is not a `page` target.
- Chrome restarted and target IDs changed.

Fix:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json"
```

Select a fresh `page` target and use its current `webSocketDebuggerUrl`.

## JavaScript Execution Errors

Common causes:

- The page has not loaded yet.
- The selector does not exist.
- The expression throws.
- The returned value is not JSON-serializable without `returnByValue`.
- Browser security rules still apply inside the page context.

Fixes:

- Use `Page.navigate --wait-event Page.loadEventFired`.
- Wait for a selector with `Runtime.evaluate` and `awaitPromise`.
- Wrap expressions in an IIFE that returns a small JSON value.
- Keep output small and targeted.

## Screenshot Problems

If stdout becomes huge, use `--save`:

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
node "$CDP_HELPER" "$WS" Page.captureScreenshot \
  '{"format":"png","captureBeyondViewport":true}' \
  --save /tmp/cdp-screenshot.png \
  --timeout 20000
```

If screenshots time out:

- Increase `--timeout`.
- Capture the viewport only by omitting `captureBeyondViewport`.
- Make sure the page is not continuously navigating or crashing.

If the saved file is invalid:

- Confirm the response contains `result.data`.
- Confirm the command was `Page.captureScreenshot`.
- Retry after `Page.enable` and page load.

## Common CDP Error Codes

- `-32000`: server-side operation failed, often because the page state or target does not support the command.
- `-32601`: method not found, often a typo or unsupported CDP domain/method.
- `-32602`: invalid params, often wrong JSON shape or missing required fields.

## Useful Recovery Sequence

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
curl -s "http://$CDP_HOST:$CDP_PORT/json"
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"({url:location.href,title:document.title,readyState:document.readyState})","returnByValue":true}'
```

If any step fails, refresh the target list before retrying WebSocket commands.
