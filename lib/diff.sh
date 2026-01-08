#!/usr/bin/env bash
set -euo pipefail

# Remove non-deterministic login/profile noise and normalize program prefix.
sanitize_stderr() {
  sed -E \
    -e '/^[^:]+\/\.profile: line [0-9]+:/d' \
    -e '/^[^:]+\/\.bashrc: /d' \
    -e '/^[^:]+\/\.bash_profile: /d' \
    -e 's#^[^:]+: #SHELL: #'
}

# If SORT_STDOUT=1, compare stdout order-independently.
normalize_stdout() {
  if [[ "${SORT_STDOUT:-0}" == "1" ]]; then
    # env output: ignore "_" because it legitimately differs between shells
    sed -E '/^_=/d' | sort
  else
    cat
  fi
}

diff_stdout() {
  local out_r="$1"
  local out_h="$2"

  if [[ "${SORT_STDOUT:-0}" == "1" ]]; then
    diff -u <(normalize_stdout < "$out_r") <(normalize_stdout < "$out_h")
  else
    diff -u "$out_r" "$out_h"
  fi
}

diff_stderr() {
  local err_r="$1"
  local err_h="$2"
  diff -u <(sanitize_stderr < "$err_r") <(sanitize_stderr < "$err_h")
}

# Compare both streams; print diffs; return 0 if equal.
compare_out_err() {
  local out_r="$1"
  local out_h="$2"
  local err_r="$3"
  local err_h="$4"

  if ! diff_stdout "$out_r" "$out_h"; then
    echo "STDOUT differs"
    return 1
  fi

  if ! diff_stderr "$err_r" "$err_h"; then
    echo "STDERR differs"
    return 1
  fi

  return 0
}

