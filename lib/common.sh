#!/usr/bin/env bash
set -euo pipefail

# Parse key=value pairs from a .t file.
# - Ignores blank lines and comments (# ...)
# - Preserves everything after the first '='
# - Supports \n and \t in values; caller can printf '%b' to interpret escapes.

t_get() {
  local file="$1"
  local key="$2"
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    # strip CR (windows files)
    line="${line%$'\r'}"

    # skip comments / empty lines
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue

    if [[ "$line" == "$key="* ]]; then
      printf "%s" "${line#"$key="}"
      return 0
    fi
  done < "$file"

  printf "%s" ""
}

# Run command with either default env (inherit) or clean env (-i) plus envspec.
# envspec formats:
#   default
#   PATH=
#   PATH=/bin:/usr/bin
#   FOO=bar;PATH=/bin   (semicolon-separated)
env_cmd_prefix() {
  local envspec="$1"

  if [[ -z "$envspec" || "$envspec" == "default" ]]; then
    printf "%s" ""
    return 0
  fi

  # clean env, then apply assignments
  # shellcheck disable=SC2145
  printf "%s" "env -i $(envspec_to_exports "$envspec") "
}

envspec_to_exports() {
  local envspec="$1"
  local out=""
  local IFS=';'
  local kv

  for kv in $envspec; do
    kv="$(echo "$kv" | sed 's/^ *//;s/ *$//')"
    [[ -z "$kv" ]] && continue
    # keep as KEY=VALUE
    out+="$kv "
  done

  printf "%s" "$out"
}

# Show file with label
print_file_block() {
  local label="$1"
  local path="$2"
  echo "---- $label ----"
  if [[ -s "$path" ]]; then
    cat "$path"
  else
    echo "(empty)"
  fi
}

