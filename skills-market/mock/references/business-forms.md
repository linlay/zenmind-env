# mock Business Forms

> 构造 `--payload` 前，务必先执行对应 create 命令的 `--help` 查看权威 schema；本文档只做旁注，以 CLI `--help` 为准。

## What This Covers

`cli-mock` 目前稳定支持 3 类业务表单：

- `leave`
- `expense`
- `procurement`

每类业务都提供无状态 CRUD 命令，但命令风格不完全相同：

- `leave`：平铺命令，使用 `create-* / get-* / update-* / delete-*`
- `expense`：资源分组命令，使用 `mock expense add|get|update|delete`
- `procurement`：资源分组命令，使用 `mock procurement create|get|update|delete`

## Create Flow With Approval Viewports

当前接入 Bash HITL + HTML viewport 的是 3 个 create 命令：

```bash
mock create-leave --payload '<json>'
mock expense add --payload '<json>'
mock procurement create --payload '<json>'
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
5. 用户批准后再真正执行对应的业务 create 命令

## Canonical Commands

### Leave

```bash
mock create-leave --payload '{"applicant_id":"E1001","department_id":"engineering","leave_type":"annual","start_date":"2026-04-20","end_date":"2026-04-22","days":3,"reason":"family_trip"}'
mock get-leave --request-id LV-7B0A3D4F10
mock update-leave --payload '{"request_id":"LV-7B0A3D4F10","applicant_id":"E1001","department_id":"engineering","leave_type":"annual","start_date":"2026-04-21","end_date":"2026-04-23","days":3,"reason":"family_trip"}'
mock delete-leave --request-id LV-7B0A3D4F10
```

关键字段：

- `applicant_id`
- `department_id`
- `leave_type`
- `start_date`
- `end_date`
- `days`
- `reason`

枚举：

- `leave_type ∈ {annual, sick, personal}`

### Expense

```bash
mock expense add --payload '{"employee":{"id":"E1001","name":"张三"},"department":{"code":"engineering","name":"工程部"},"expense_type":"travel","currency":"CNY","total_amount":1280.5,"submitted_at":"2026-04-14T10:30:00+08:00","items":[{"category":"transport","amount":800,"invoice_id":"INV-001","occurred_on":"2026-04-10","description":"flight"},{"category":"hotel","amount":480.5,"invoice_id":"INV-002","occurred_on":"2026-04-11","description":"hotel"}]}'
mock expense get --request-id EX-14C0A7B992
mock expense update --request-id EX-14C0A7B992 --payload '{"employee":{"id":"E1001","name":"张三"},"department":{"code":"engineering","name":"工程部"},"expense_type":"travel","currency":"CNY","total_amount":1280.5,"submitted_at":"2026-04-14T10:30:00+08:00","items":[{"category":"transport","amount":800,"invoice_id":"INV-001","occurred_on":"2026-04-10","description":"flight"},{"category":"hotel","amount":480.5,"invoice_id":"INV-002","occurred_on":"2026-04-11","description":"hotel"}]}'
mock expense delete --request-id EX-14C0A7B992
```

关键字段：

- `employee.id`
- `employee.name`
- `department.code`
- `department.name`
- `expense_type`
- `currency`
- `total_amount`
- `items[].category`
- `items[].amount`
- `items[].invoice_id`
- `items[].occurred_on`
- `items[].description`
- `submitted_at`

枚举：

- `currency ∈ {CNY, USD}`
- `expense_type ∈ {travel, meal, equipment, other}`
- `items[].category ∈ {transport, hotel, meal, other}`

### Procurement

```bash
mock procurement create --payload '{"requester_id":"E1001","department":"engineering","budget_code":"RD-2026-001","reason":"team expansion","delivery_city":"Shanghai","items":[{"name":"MacBook Pro","quantity":2,"unit_price":18999,"vendor":"Apple"}],"approvers":["MGR100","FIN200"],"requested_at":"2026-04-14T11:00:00+08:00"}'
mock procurement get --request-id PR-BA08D42C31
mock procurement update --request-id PR-BA08D42C31 --payload '{"requester_id":"E1001","department":"engineering","budget_code":"RD-2026-001","reason":"team expansion","delivery_city":"Shanghai","items":[{"name":"MacBook Pro","quantity":2,"unit_price":18999,"vendor":"Apple"}],"approvers":["MGR100","FIN200"],"requested_at":"2026-04-14T11:00:00+08:00"}'
mock procurement delete --request-id PR-BA08D42C31
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

字典/字段说明：

- `department` 使用部门代码，例如 `engineering`
- `approvers[]` 使用员工/审批人 ID，例如 `MGR100`
- `items[]` 必须包含 `name / quantity / unit_price / vendor`

## Result Enums

create / add / update:

- `submitted`
- `approved`
- `rejected`

get:

- `found`
- `not_found`

delete:

- `deleted`
- `not_found`

## When To Use Which Path

- 只需要稳定 JSON 结果或脚本断言：直接调用对应业务命令，并显式加 `--output json`
- 需要演示或联调表单体验：走对应 HTML form viewport
- 需要“填表 -> 用户确认 -> 再执行 mock 命令”：一定使用 inline `--payload` create 命令，让 approval viewport 能预填 payload
- 只想更新已有记录：当前以纯 CLI 为主，不是 viewport-first 场景

## Validation Notes

- `leave`：`start_date` 不能晚于 `end_date`
- `expense`：`total_amount` 必须等于 `items[].amount` 之和
- `procurement`：采购总额超过 `50000` 会返回 `budget exceeded`
- `update-leave`：`request_id` 放在 payload 里
- `get` / `delete` / 某些 `update`：`--request-id` 前缀必须和业务类型一致
