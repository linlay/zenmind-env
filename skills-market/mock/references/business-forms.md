# mock Business Forms

## What This Covers

`cli-mock` 目前稳定支持 3 类业务表单：

- `leave`
- `expense`
- `procurement`

每类业务都提供无状态 CRUD 顶层命令：

- `create-*`
- `get-*`
- `update-*`
- `delete-*`

## Create Flow With Approval Viewports

当前接入 Bash HITL + HTML viewport 的是 3 个 create 命令：

```bash
mock create-leave --payload '<json>'
mock create-expense --payload '<json>'
mock create-procurement --payload '<json>'
```

对应 viewport：

- `leave_form`
- `expense_form`
- `procurement_form`

推荐流程：

1. 先在表单 viewport 中生成 inline `--payload` 命令
2. 让宿主执行该命令
3. skill 的 `.bash-hooks` 拦截 create 命令
4. 用户在 approval viewport 里核对 payload
5. 用户批准后再真正执行 `mock create-*`

## Canonical Commands

### Leave

```bash
mock create-leave --payload '{"employee_id":"E1001","employee_name":"Lin","leave_type":"annual","start_date":"2026-04-20","end_date":"2026-04-22","days":3,"reason":"family_trip","handover_to":"E2001","urgent_contact":"13800138000"}'
mock get-leave --request-id LV-7B0A3D4F10
mock update-leave --payload '{"request_id":"LV-7B0A3D4F10","employee_id":"E1001","employee_name":"Lin","leave_type":"annual","start_date":"2026-04-21","end_date":"2026-04-23","days":3,"reason":"family_trip","handover_to":"E2001","urgent_contact":"13800138000"}'
mock delete-leave --request-id LV-7B0A3D4F10
```

关键字段：

- `employee_id`
- `employee_name`
- `leave_type`
- `start_date`
- `end_date`
- `days`
- `reason`
- `handover_to`
- `urgent_contact`

### Expense

```bash
mock create-expense --payload '{"employee_id":"E1001","department":"engineering","expense_type":"travel","currency":"CNY","total_amount":1280.5,"items":[{"category":"transport","amount":800,"invoice_id":"INV-001","occurred_on":"2026-04-10","description":"flight"},{"category":"hotel","amount":480.5,"invoice_id":"INV-002","occurred_on":"2026-04-11","description":"hotel"}],"submitted_at":"2026-04-14T10:30:00+08:00"}'
mock get-expense --request-id EX-14C0A7B992
mock update-expense --request-id EX-14C0A7B992 --payload '{"employee_id":"E1001","department":"engineering","expense_type":"travel","currency":"CNY","total_amount":1280.5,"items":[{"category":"transport","amount":800,"invoice_id":"INV-001","occurred_on":"2026-04-10","description":"flight"},{"category":"hotel","amount":480.5,"invoice_id":"INV-002","occurred_on":"2026-04-11","description":"hotel"}],"submitted_at":"2026-04-14T10:30:00+08:00"}'
mock delete-expense --request-id EX-14C0A7B992
```

关键字段：

- `employee_id`
- `department`
- `expense_type`
- `currency`
- `total_amount`
- `items[].category`
- `items[].amount`
- `items[].invoice_id`
- `items[].occurred_on`
- `items[].description`
- `submitted_at`

### Procurement

```bash
mock create-procurement --payload '{"requester_id":"E1001","department":"engineering","budget_code":"RD-2026-001","reason":"team expansion","delivery_city":"Shanghai","items":[{"name":"MacBook Pro","quantity":2,"unit_price":18999,"vendor":"Apple"}],"approvers":["MGR100","FIN200"],"requested_at":"2026-04-14T11:00:00+08:00"}'
mock get-procurement --request-id PR-BA08D42C31
mock update-procurement --request-id PR-BA08D42C31 --payload '{"requester_id":"E1001","department":"engineering","budget_code":"RD-2026-001","reason":"team expansion","delivery_city":"Shanghai","items":[{"name":"MacBook Pro","quantity":2,"unit_price":18999,"vendor":"Apple"}],"approvers":["MGR100","FIN200"],"requested_at":"2026-04-14T11:00:00+08:00"}'
mock delete-procurement --request-id PR-BA08D42C31
```

关键字段：

- `requester_id`
- `department`
- `budget_code`
- `reason`
- `delivery_city`
- `items[].name`
- `items[].quantity`
- `items[].unit_price`
- `items[].vendor`
- `approvers[]`
- `requested_at`

## Result Enums

`create-*` / `update-*`:

- `submitted`
- `approved`
- `rejected`

`get-*`:

- `found`
- `not_found`

`delete-*`:

- `deleted`
- `not_found`

## When To Use Which Path

- 只需要稳定 JSON 结果或脚本断言：直接调用 `mock create-*` / `get-*` / `update-*` / `delete-*`
- 需要演示或联调表单体验：走对应 HTML form viewport
- 需要“填表 -> 用户确认 -> 再执行 mock 命令”：一定使用 inline `--payload` create 命令，让 approval viewport 能预填 payload
- 只想更新已有记录：当前以纯 CLI 为主，不是 viewport-first 场景

## Validation Notes

- `leave`：`start_date` 不能晚于 `end_date`
- `expense`：`total_amount` 必须等于 `items[].amount` 之和
- `procurement`：采购总额超过 `50000` 会返回 `budget exceeded`
- `update-leave`：`request_id` 放在 payload 里
- `get-*` / `delete-*` / 某些 `update-*`：`--request-id` 前缀必须和业务类型一致
