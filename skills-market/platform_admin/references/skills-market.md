# Skills Market

共享技能目录在容器内位于 `/skills-market/<skill-id>/`。

## 布局契约

- 必需文件：`/skills-market/<skill-id>/SKILL.md`
- 常见可选子目录：
  - `references/`
  - `scripts/`
  - `assets/`
- runner 只从 `skills/<skill-id>/SKILL.md` 加载 skill 元信息与正文
- 隐藏文件和隐藏目录会被忽略
- frontmatter 含 `scaffold: true` 的 skill 只作为脚手架，不会进入运行时 skill registry

## 阅读顺序

1. 先读 `SKILL.md`
2. 按 `SKILL.md` 的导航，只展开与当前任务相关的 `references/`
3. 只有确实要执行或修改脚本时，才读 `scripts/`

## 默认权限

- 默认只读浏览
- 可以：
  - 总结 skill 的能力与适用场景
  - 指出应该进一步阅读哪个 reference
  - 审查目录结构是否完整
- 无明确要求时不要：
  - 改写共享 skill
  - 顺手调整 frontmatter 或脚本
  - 大范围重组目录

## 同步与生效

- `skills-market` 目录变更会刷新 skill registry，但不会触发 agent reload
- agent 在声明 `skillConfig.skills` 后，runner 会把对应 market skill 复制到该 agent 本地 `skills/` 目录
- 因此，改共享 skill 并不等于某个已同步 agent 会立刻使用到新内容；判断是否生效时，要区分共享 market 内容与 agent 本地拷贝

## 审查重点

- `SKILL.md` frontmatter 是否有 `name` 与 `description`
- skill 是否做了渐进式披露，而不是把所有细节塞进一个文件
- `references/`、`scripts/`、`assets/` 是否职责清晰
- 如果问题与“为什么 agent 没读到新 skill”有关，要同时检查共享 market 内容和 agent 本地 `skills/` 拷贝

## 推荐检查顺序

1. `ls /skills-market`
2. `sed -n '1,120p' /skills-market/<skill-id>/SKILL.md`
3. 根据 `SKILL.md` 再展开相关 `references/` 或 `scripts/`
