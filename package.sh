#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$SCRIPT_DIR"
DIST_DIR="$WORKSPACE_ROOT/dist"
PACKAGE_STEM="zenmind-env-$(date '+%Y%m%d-%H%M%S')"
STAGE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/zenmind-env-package.XXXXXX")"
PAYLOAD_ROOT="$STAGE_ROOT/$PACKAGE_STEM"
ARCHIVE_PATH="$DIST_DIR/$PACKAGE_STEM.zip"

usage() {
  cat <<'EOF'
用法:
  ./package.sh

说明:
  按 zenmind-env 的目录约定打包发布内容。
  - 打包 example 模板
  - 不打包 demo 内容
  - 不打包本地 live/runtime 数据
  - 对部分目录执行显式重命名，例如:
    registries.example/ -> registries/
    owner.example/ -> owner/
EOF
}

cleanup() {
  rm -rf "$STAGE_ROOT"
}

trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf '缺少依赖命令: %s\n' "$1" >&2
    exit 1
  fi
}

strip_example_segments() {
  local path="$1"
  local part
  local output=()

  IFS='/' read -r -a parts <<<"$path"
  for part in "${parts[@]}"; do
    part="${part//.example./.}"
    output+=("${part%.example}")
  done

  local joined=""
  local index
  for index in "${!output[@]}"; do
    if [[ "$index" -gt 0 ]]; then
      joined+="/"
    fi
    joined+="${output[$index]}"
  done

  printf '%s\n' "$joined"
}

path_has_example_segment() {
  local path="$1"
  local part

  IFS='/' read -r -a parts <<<"$path"
  for part in "${parts[@]}"; do
    if [[ "$part" == *.example ]]; then
      return 0
    fi
  done

  return 1
}

ensure_parent_dir() {
  local rel_path="$1"
  local parent_dir

  parent_dir="$(dirname "$PAYLOAD_ROOT/$rel_path")"
  mkdir -p "$parent_dir"
}

ensure_dir_in_payload() {
  local rel_dir="$1"
  local dest_dir="$PAYLOAD_ROOT/$rel_dir"

  if [[ -f "$dest_dir" ]]; then
    printf '打包目标冲突，期望目录但已存在文件: %s\n' "$rel_dir" >&2
    exit 1
  fi

  mkdir -p "$dest_dir"
}

copy_file_to_payload() {
  local src_path="$1"
  local rel_path="$2"
  local dest_path="$PAYLOAD_ROOT/$rel_path"

  ensure_parent_dir "$rel_path"
  if [[ -e "$dest_path" ]]; then
    printf '打包目标冲突，重复写入: %s\n' "$rel_path" >&2
    exit 1
  fi

  cp -p "$src_path" "$dest_path"
}

copy_top_level_files() {
  local path
  local rel

  while IFS= read -r -d '' path; do
    rel="${path#$WORKSPACE_ROOT/}"
    case "$rel" in
      .DS_Store)
        continue
        ;;
    esac
    copy_file_to_payload "$path" "$rel"
  done < <(find "$WORKSPACE_ROOT" -maxdepth 1 -type f -print0)
}

copy_tree() {
  local src_root="$1"
  local dest_root="$2"
  local mode="$3"
  local kind="$4"
  local path
  local rel
  local mapped_rel
  local dest_rel

  [[ -d "$src_root" ]] || return 0
  ensure_dir_in_payload "$dest_root"

  while IFS= read -r -d '' path; do
    rel="${path#$src_root/}"

    case "$kind" in
      generic)
        case "$rel" in
          .DS_Store|*/.DS_Store)
            continue
            ;;
        esac
        ;;
      agents)
        case "$rel" in
          .DS_Store|*/.DS_Store|*.demo|*.demo/*|*/skills|*/skills/*)
            continue
            ;;
          zenmi|zenmi/agent.yml|zenmi/AGENTS.md|zenmi/SOUL.md|zenmi/agent.real.yml|zenmi/agent.real\ copy.yml|zenmi/AGENTS.real.md|zenmi/agent.example.yml|zenmi/AGENTS.example.md|zenmi/SOUL.example.md)
            continue
            ;;
        esac
        ;;
      chats)
        case "$rel" in
          .DS_Store|*/.DS_Store)
            continue
            ;;
          *.example.jsonl|*.example|*.example/*)
            ;;
          *)
            continue
            ;;
        esac
        ;;
      root)
        case "$rel" in
          .DS_Store|*/.DS_Store)
            continue
            ;;
        esac
        if ! path_has_example_segment "$rel"; then
          continue
        fi
        ;;
      schedules|teams)
        case "$rel" in
          .DS_Store|*/.DS_Store|*.demo.yml|*.demo.yaml|*.demo|*.demo/*)
            continue
            ;;
        esac
        ;;
      *)
        printf '未知的 copy_tree 类型: %s\n' "$kind" >&2
        exit 1
        ;;
    esac

    mapped_rel="$rel"
    case "$mode" in
      preserve)
        ;;
      strip-example)
        mapped_rel="$(strip_example_segments "$mapped_rel")"
        ;;
      *)
        printf '未知的路径映射模式: %s\n' "$mode" >&2
        exit 1
        ;;
    esac

    dest_rel="$dest_root"
    if [[ -n "$mapped_rel" ]]; then
      dest_rel+="/$mapped_rel"
    fi

    if [[ -d "$path" ]]; then
      ensure_dir_in_payload "$dest_rel"
      continue
    fi

    copy_file_to_payload "$path" "$dest_rel"
  done < <(find "$src_root" -mindepth 1 -print0)
}

main() {
  if (( $# > 0 )); then
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 1
        ;;
    esac
  fi

  require_cmd zip

  mkdir -p "$DIST_DIR" "$PAYLOAD_ROOT"

  copy_top_level_files
  copy_tree "$WORKSPACE_ROOT/agents" "agents" "strip-example" "agents"
  copy_tree "$WORKSPACE_ROOT/skills-market" "skills-market" "preserve" "generic"
  copy_tree "$WORKSPACE_ROOT/tools" "tools" "preserve" "generic"
  copy_tree "$WORKSPACE_ROOT/pan" "pan" "preserve" "generic"
  copy_tree "$WORKSPACE_ROOT/schedules" "schedules" "strip-example" "schedules"
  copy_tree "$WORKSPACE_ROOT/teams" "teams" "strip-example" "teams"
  copy_tree "$WORKSPACE_ROOT/chats" "chats" "preserve" "chats"
  copy_tree "$WORKSPACE_ROOT/root" "root" "strip-example" "root"
  copy_tree "$WORKSPACE_ROOT/registries.example" "registries" "strip-example" "generic"
  copy_tree "$WORKSPACE_ROOT/owner.example" "owner" "strip-example" "generic"

  (
    cd "$STAGE_ROOT"
    zip -qr "$ARCHIVE_PATH" "$PACKAGE_STEM"
  )

  printf 'Created archive: %s\n' "$ARCHIVE_PATH"
}

main "$@"
