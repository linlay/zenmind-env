#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$SCRIPT_DIR"
DIST_DIR="$WORKSPACE_ROOT/dist"

usage() {
  cat <<'EOF'
Usage:
  ./package-httpx-config.sh <domain>

Example:
  ./package-httpx-config.sh example.site.net
EOF
}

if (( $# != 1 )); then
  usage >&2
  exit 1
fi

domain="$1"
archive_path="$DIST_DIR/httpx-config-${domain}.zip"

package_files=(
  "root/.config/httpx/${domain}.toml"
  "root/.local/secret/httpx/${domain}.json"
)

missing_files=()
for rel_path in "${package_files[@]}"; do
  if [[ ! -f "$WORKSPACE_ROOT/$rel_path" ]]; then
    missing_files+=("$rel_path")
  fi
done

if (( ${#missing_files[@]} > 0 )); then
  printf 'Missing required file: %s\n' "${missing_files[@]}" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

rm -f "$archive_path"
(
  cd "$WORKSPACE_ROOT"
  zip -q "$archive_path" "${package_files[@]}"
)

printf 'Created archive: %s\n' "$archive_path"
printf 'Included files:\n'
printf '  %s\n' "${package_files[@]}"
