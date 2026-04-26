# CDP Commands Reference

Use `curl` for HTTP endpoints and the bundled Node helper for WebSocket CDP commands.

```bash
CDP_HELPER=/Users/linlay/Project/zenmind/zenmind-env/skills-market/cdp/scripts/cdp-send.mjs
```

## Command Surface

- There is no standalone `cdp` binary.
- Do not run `cdp --help` or `which cdp`.
- HTTP discovery and target management use `curl`.
- Page operations use `node "$CDP_HELPER"`.
- macOS `open` can open a URL, but it does not prove CDP control.

## HTTP Endpoints

Check browser-level CDP metadata:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/version"
```

List targets:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json"
curl -s "http://$CDP_HOST:$CDP_PORT/json/list"
```

Create a new tab:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/new?https://example.com"
```

Activate a target:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/activate/<target-id>"
```

Close a target only when the user explicitly asks and the tab is known to be safe to close:

```bash
curl -s "http://$CDP_HOST:$CDP_PORT/json/close/<target-id>"
```

## Page Domain

Enable page events:

```bash
node "$CDP_HELPER" "$WS" Page.enable '{}'
```

Navigate:

```bash
node "$CDP_HELPER" "$WS" Page.navigate '{"url":"https://example.com"}'
```

Reload:

```bash
node "$CDP_HELPER" "$WS" Page.reload '{"ignoreCache":true}'
```

Capture screenshot:

```bash
node "$CDP_HELPER" "$WS" Page.captureScreenshot \
  '{"format":"png","captureBeyondViewport":true}' \
  --save /tmp/cdp-screenshot.png
```

Common `Page.captureScreenshot` params:

- `format`: `png`, `jpeg`, or `webp`
- `quality`: JPEG/WebP quality from `0` to `100`
- `captureBeyondViewport`: include content beyond the viewport when supported

## Runtime Domain

Evaluate JavaScript:

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"document.title","returnByValue":true}'
```

Useful params:

- `expression`: JavaScript source to evaluate.
- `returnByValue`: return JSON-serializable values directly.
- `awaitPromise`: wait for Promise resolution.
- `userGesture`: treat evaluation as a user gesture when Chrome allows it.

Async example:

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"new Promise(r => setTimeout(() => r(location.href), 500))","awaitPromise":true,"returnByValue":true}'
```

## DOM Domain

Get the document:

```bash
node "$CDP_HELPER" "$WS" DOM.getDocument '{"depth":1}'
```

Query one selector:

```bash
node "$CDP_HELPER" "$WS" DOM.querySelector \
  '{"nodeId":1,"selector":"h1"}'
```

Query all selectors:

```bash
node "$CDP_HELPER" "$WS" DOM.querySelectorAll \
  '{"nodeId":1,"selector":"button"}'
```

Get outer HTML:

```bash
node "$CDP_HELPER" "$WS" DOM.getOuterHTML '{"nodeId":1}'
```

Get box model:

```bash
node "$CDP_HELPER" "$WS" DOM.getBoxModel '{"nodeId":1}'
```

For bash workflows, `Runtime.evaluate` with `document.querySelector` is often simpler because it avoids carrying `nodeId` across calls.

## Input Domain

Mouse press:

```bash
node "$CDP_HELPER" "$WS" Input.dispatchMouseEvent \
  '{"type":"mousePressed","x":100,"y":100,"button":"left","clickCount":1}'
```

Mouse release:

```bash
node "$CDP_HELPER" "$WS" Input.dispatchMouseEvent \
  '{"type":"mouseReleased","x":100,"y":100,"button":"left","clickCount":1}'
```

Key event:

```bash
node "$CDP_HELPER" "$WS" Input.dispatchKeyEvent \
  '{"type":"keyDown","key":"Enter","code":"Enter","windowsVirtualKeyCode":13}'
node "$CDP_HELPER" "$WS" Input.dispatchKeyEvent \
  '{"type":"keyUp","key":"Enter","code":"Enter","windowsVirtualKeyCode":13}'
```

Insert text:

```bash
node "$CDP_HELPER" "$WS" Input.insertText '{"text":"hello"}'
```

## Network Domain

Enable network events:

```bash
node "$CDP_HELPER" "$WS" Network.enable '{}'
```

Disable network events:

```bash
node "$CDP_HELPER" "$WS" Network.disable '{}'
```

## Common Patterns

### Navigate, Wait, Screenshot

```bash
node "$CDP_HELPER" "$WS" Page.navigate \
  '{"url":"https://example.com"}' \
  --wait-event Page.loadEventFired \
  --timeout 15000
node "$CDP_HELPER" "$WS" Page.captureScreenshot \
  '{"format":"png","captureBeyondViewport":true}' \
  --save /tmp/example.png
```

### Click Selector With JS

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"document.querySelector(\"button[type=submit]\")?.click()","returnByValue":true}'
```

### Fill Form With JS

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"const el=document.querySelector(\"input[name=email]\"); el.value=\"user@example.com\"; el.dispatchEvent(new Event(\"input\",{bubbles:true})); true","returnByValue":true}'
```

### Real Click By Selector Center

Get coordinates:

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"(() => { const el=document.querySelector(\"button\"); const r=el.getBoundingClientRect(); return {x:r.left+r.width/2,y:r.top+r.height/2}; })()","returnByValue":true}'
```

Then send `Input.dispatchMouseEvent` at the returned coordinates.

### Wait For A Selector

```bash
node "$CDP_HELPER" "$WS" Runtime.evaluate \
  '{"expression":"new Promise((resolve,reject)=>{const start=Date.now();const timer=setInterval(()=>{if(document.querySelector(\"h1\")){clearInterval(timer);resolve(true)}else if(Date.now()-start>10000){clearInterval(timer);reject(new Error(\"selector timeout\"))}},100)})","awaitPromise":true,"returnByValue":true}' \
  --timeout 12000
```
