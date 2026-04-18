#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
CHATS_DIR="$ROOT_DIR/chats"
CHATS_DB="$CHATS_DIR/chats.db"
MEMORY_DIR="$ROOT_DIR/memory"
MEMORY_DB="$MEMORY_DIR/memory.db"
ARCHIVE_DIR="$ROOT_DIR/archive"

TARGET=""
RANGE=""
DRY_RUN=0
AUTO_YES=0

usage() {
  cat <<'EOF'
用法:
  ./archive.sh
  ./archive.sh chats|memory month|week|day|all [--dry-run] [--yes]

说明:
  chats   归档聊天记录
  memory  归档记忆

  month   一个月以前
  week    一周以前
  day     一天以前
  all     全部

选项:
  --dry-run  只预览，不执行归档
  --yes      跳过最终确认，直接执行
  --help     显示帮助
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少依赖命令: $1" >&2
    exit 1
  fi
}

target_label() {
  case "$1" in
    chats) echo "聊天记录" ;;
    memory) echo "记忆" ;;
    *) echo "$1" ;;
  esac
}

range_label() {
  case "$1" in
    month) echo "一个月以前" ;;
    week) echo "一周以前" ;;
    day) echo "一天以前" ;;
    all) echo "全部" ;;
    *) echo "$1" ;;
  esac
}

range_modifier() {
  case "$1" in
    month) echo "-1 month" ;;
    week) echo "-7 days" ;;
    day) echo "-1 day" ;;
    all) echo "" ;;
    *)
      echo "不支持的时间范围: $1" >&2
      exit 1
      ;;
  esac
}

is_valid_target() {
  [[ "$1" == "chats" || "$1" == "memory" ]]
}

is_valid_range() {
  [[ "$1" == "month" || "$1" == "week" || "$1" == "day" || "$1" == "all" ]]
}

choose_target() {
  echo "请选择归档对象:"
  select option in "聊天记录" "记忆" "取消"; do
    case "$REPLY" in
      1) TARGET="chats"; break ;;
      2) TARGET="memory"; break ;;
      3)
        echo "已取消。"
        exit 0
        ;;
      *)
        echo "请输入 1、2 或 3。"
        ;;
    esac
  done
}

choose_range() {
  echo "请选择归档时间范围:"
  select option in "一个月以前" "一周以前" "一天以前" "全部" "取消"; do
    case "$REPLY" in
      1) RANGE="month"; break ;;
      2) RANGE="week"; break ;;
      3) RANGE="day"; break ;;
      4) RANGE="all"; break ;;
      5)
        echo "已取消。"
        exit 0
        ;;
      *)
        echo "请输入 1、2、3、4 或 5。"
        ;;
    esac
  done
}

confirm_or_exit() {
  if [[ "$AUTO_YES" -eq 1 ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    echo "当前不是交互终端，请加 --yes 以跳过确认。" >&2
    exit 1
  fi

  printf "确认执行归档吗？输入 yes 继续: "
  read -r answer
  if [[ "$answer" != "yes" ]]; then
    echo "已取消。"
    exit 0
  fi
}

preview_chats() {
  local where_sql="$1"
  sqlite3 -tabs "$CHATS_DB" \
    "SELECT CHAT_ID_, datetime(UPDATED_AT_ / 1000, 'unixepoch', 'localtime'), CHAT_NAME_ FROM CHATS WHERE $where_sql ORDER BY UPDATED_AT_ ASC LIMIT 10;"
}

preview_memories() {
  local where_sql="$1"
  sqlite3 -tabs "$MEMORY_DB" \
    "SELECT ID_, datetime(TS_ / 1000, 'unixepoch', 'localtime'), IFNULL(CHAT_ID_, ''), substr(replace(replace(SUMMARY_, char(10), ' '), char(13), ' '), 1, 80) FROM MEMORIES WHERE $where_sql ORDER BY TS_ ASC LIMIT 10;"
}

build_where_sql() {
  local column_name="$1"
  local modifier
  modifier="$(range_modifier "$RANGE")"
  if [[ "$RANGE" == "all" ]]; then
    echo "1=1"
  else
    printf "%s < CAST(strftime('%%s', 'now', '%s') AS INTEGER) * 1000" "$column_name" "$modifier"
  fi
}

write_manifest() {
  local manifest_path="$1"
  local archived_count="$2"
  local selected_label="$3"
  local range_text="$4"
  local cutoff_text="$5"
  cat >"$manifest_path" <<EOF
target=$selected_label
range=$range_text
cutoff=$cutoff_text
archived_count=$archived_count
archived_at=$(date '+%Y-%m-%d %H:%M:%S %z')
EOF
}

archive_chats() {
  local where_sql="$1"
  local preview_count
  local selected_file moved_ids_file sql_file archive_batch_dir archive_db manifest_path
  local moved_count=0

  selected_file="$(mktemp)"
  moved_ids_file="$(mktemp)"

  sqlite3 -tabs "$CHATS_DB" \
    "SELECT CHAT_ID_, CHAT_NAME_, UPDATED_AT_ FROM CHATS WHERE $where_sql ORDER BY UPDATED_AT_ ASC;" >"$selected_file"

  preview_count="$(wc -l <"$selected_file" | tr -d ' ')"
  echo "命中聊天记录: $preview_count"
  if [[ "$preview_count" -eq 0 ]]; then
    rm -f "$selected_file" "$moved_ids_file"
    return 0
  fi

  echo
  echo "预览前 10 条:"
  while IFS=$'\t' read -r chat_id updated_at chat_name; do
    printf '  - %s | %s | %s\n' "$chat_id" "$updated_at" "$chat_name"
  done < <(preview_chats "$where_sql")

  if [[ "$DRY_RUN" -eq 1 ]]; then
    rm -f "$selected_file" "$moved_ids_file"
    return 0
  fi

  confirm_or_exit

  archive_batch_dir="$ARCHIVE_DIR/chats/$(date '+%Y%m%d-%H%M%S')"
  archive_db="$archive_batch_dir/chats.db"
  manifest_path="$archive_batch_dir/manifest.txt"
  mkdir -p "$archive_batch_dir"

  while IFS=$'\t' read -r chat_id _chat_name _updated_at; do
    local moved=0
    if [[ -f "$CHATS_DIR/$chat_id.jsonl" ]]; then
      mv "$CHATS_DIR/$chat_id.jsonl" "$archive_batch_dir/"
      moved=1
    fi
    if [[ -d "$CHATS_DIR/$chat_id" ]]; then
      mv "$CHATS_DIR/$chat_id" "$archive_batch_dir/"
      moved=1
    fi
    if [[ "$moved" -eq 1 ]]; then
      printf '%s\n' "$chat_id" >>"$moved_ids_file"
      moved_count=$((moved_count + 1))
    fi
  done <"$selected_file"

  if [[ "$moved_count" -eq 0 ]]; then
    rmdir "$archive_batch_dir" 2>/dev/null || true
    rm -f "$selected_file" "$moved_ids_file"
    echo "没有找到可移动的聊天文件或附件目录，未修改数据库。"
    return 0
  fi

  sql_file="$(mktemp)"
  {
    printf "ATTACH '%s' AS live;\n" "$CHATS_DB"
    echo "CREATE TABLE CHATS AS SELECT * FROM live.CHATS WHERE 0;"
    while IFS= read -r chat_id; do
      printf "INSERT INTO main.CHATS SELECT * FROM live.CHATS WHERE CHAT_ID_ = '%s';\n" "$chat_id"
    done <"$moved_ids_file"
  } >"$sql_file"
  sqlite3 "$archive_db" <"$sql_file"

  {
    echo "BEGIN;"
    while IFS= read -r chat_id; do
      printf "DELETE FROM CHATS WHERE CHAT_ID_ = '%s';\n" "$chat_id"
    done <"$moved_ids_file"
    echo "COMMIT;"
  } | sqlite3 "$CHATS_DB"

  write_manifest "$manifest_path" "$moved_count" "$(target_label "$TARGET")" "$(range_label "$RANGE")" "$(cutoff_text "$where_sql")"
  rm -f "$selected_file" "$moved_ids_file" "$sql_file"

  echo
  echo "已归档聊天记录: $moved_count"
  echo "归档目录: $archive_batch_dir"
}

archive_memories() {
  local where_sql="$1"
  local preview_count archive_batch_dir archive_db manifest_path

  preview_count="$(sqlite3 "$MEMORY_DB" "SELECT COUNT(*) FROM MEMORIES WHERE $where_sql;")"
  echo "命中记忆: $preview_count"
  if [[ "$preview_count" -eq 0 ]]; then
    return 0
  fi

  echo
  echo "预览前 10 条:"
  while IFS=$'\t' read -r memory_id ts_local chat_id summary; do
    printf '  - %s | %s | chat=%s | %s\n' "$memory_id" "$ts_local" "${chat_id:-N/A}" "$summary"
  done < <(preview_memories "$where_sql")

  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi

  confirm_or_exit

  archive_batch_dir="$ARCHIVE_DIR/memory/$(date '+%Y%m%d-%H%M%S')"
  archive_db="$archive_batch_dir/memory.db"
  manifest_path="$archive_batch_dir/manifest.txt"
  mkdir -p "$archive_batch_dir"

  sqlite3 "$MEMORY_DB" \
    "ATTACH '$archive_db' AS archive;
     CREATE TABLE archive.MEMORIES AS SELECT * FROM main.MEMORIES WHERE $where_sql;"

  sqlite3 "$MEMORY_DB" \
    "DELETE FROM MEMORIES WHERE $where_sql;"

  write_manifest "$manifest_path" "$preview_count" "$(target_label "$TARGET")" "$(range_label "$RANGE")" "$(cutoff_text "$where_sql")"

  echo
  echo "已归档记忆: $preview_count"
  echo "归档目录: $archive_batch_dir"
}

cutoff_text() {
  if [[ "$RANGE" == "all" ]]; then
    echo "全部"
    return 0
  fi

  local modifier
  modifier="$(range_modifier "$RANGE")"
  sqlite3 ":memory:" "SELECT datetime(strftime('%s', 'now', '$modifier'), 'unixepoch', 'localtime');"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      chats|memory)
        if [[ -n "$TARGET" && "$TARGET" != "$1" ]]; then
          echo "归档对象重复指定: $1" >&2
          exit 1
        fi
        TARGET="$1"
        ;;
      month|week|day|all)
        if [[ -n "$RANGE" && "$RANGE" != "$1" ]]; then
          echo "时间范围重复指定: $1" >&2
          exit 1
        fi
        RANGE="$1"
        ;;
      --dry-run)
        DRY_RUN=1
        ;;
      --yes)
        AUTO_YES=1
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        echo "未知参数: $1" >&2
        echo
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

main() {
  require_cmd sqlite3

  parse_args "$@"

  if [[ -z "$TARGET" ]]; then
    if [[ ! -t 0 ]]; then
      echo "当前不是交互终端，请显式传入 chats 或 memory。" >&2
      exit 1
    fi
    choose_target
  fi
  if [[ -z "$RANGE" ]]; then
    if [[ ! -t 0 ]]; then
      echo "当前不是交互终端，请显式传入 month、week、day 或 all。" >&2
      exit 1
    fi
    choose_range
  fi

  if ! is_valid_target "$TARGET"; then
    echo "不支持的归档对象: $TARGET" >&2
    exit 1
  fi
  if ! is_valid_range "$RANGE"; then
    echo "不支持的时间范围: $RANGE" >&2
    exit 1
  fi

  if [[ "$TARGET" == "chats" && ! -f "$CHATS_DB" ]]; then
    echo "未找到聊天数据库: $CHATS_DB" >&2
    exit 1
  fi
  if [[ "$TARGET" == "memory" && ! -f "$MEMORY_DB" ]]; then
    echo "未找到记忆数据库: $MEMORY_DB" >&2
    exit 1
  fi

  echo "归档对象: $(target_label "$TARGET")"
  echo "时间范围: $(range_label "$RANGE")"
  echo "截止时间: $(cutoff_text)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "模式: 仅预览"
  fi
  echo

  mkdir -p "$ARCHIVE_DIR"

  if [[ "$TARGET" == "chats" ]]; then
    archive_chats "$(build_where_sql "UPDATED_AT_")"
  else
    archive_memories "$(build_where_sql "TS_")"
  fi
}

main "$@"
