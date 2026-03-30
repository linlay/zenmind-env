# owner/

`owner/` 位于 `/zenmind-root/owner`，是用户身份、偏好与长期画像的目录。

当前目录约定：

- `OWNER.md`：长期 owner 主文档
- `BOOTSTRAP.md`：首次启动阶段的一次性引导文档

## 修改原则

- 先读目录列表，再决定要读哪一个文件
- 尽量保留原有结构、标题与语气
- 只改与用户请求直接相关的段落
- 不把临时调试细节、一次性操作记录写成长期制度
- 如果 `OWNER.md` 内容非常少，允许在用户目标明确时补出最小结构，但不要凭空扩写成大而空的手册
- 如果 `OWNER.md` 已完成初始化，应删除 `BOOTSTRAP.md`

## 推荐检查顺序

1. `find /zenmind-root/owner -maxdepth 1 -type f | sort`
2. `sed -n '1,120p' /zenmind-root/owner/BOOTSTRAP.md`
3. `sed -n '1,160p' /zenmind-root/owner/OWNER.md`
4. 目标明确后再全文读取相关文件
5. 修改后回读相关段落

## 输出纪律

- 回复里说明修改了哪个文件、为什么改
- 如果文档仍然很短，也不要假装它已经是一套完整制度
