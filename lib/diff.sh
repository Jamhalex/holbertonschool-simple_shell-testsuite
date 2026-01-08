#!/usr/bin/env bash
set -euo pipefail

run_with_env() {
  local bin="$1"
  local input="$2"
  local envspec="$3"
  local out="$4"
  local err="$5"
  local status_file="$6"

  (
    # isolate env if requested
    if [[ "$envspec" == "default" || -z "$envspec" ]]; then
      :
    else
      # start from clean env, then set envspec
      env -i bash -lc "export $envspec; printf '%b' '$input' | $bin" \
        >"$out" 2>"$err"
      echo "$?" >"$status_file"
      exit 0
    fi

    printf '%b' "$input" | "$bin" >"$out" 2>"$err"
    echo "$?" >"$status_file"
  )
}

run_test() {
  local hsh="$1"
  local ref="$2"
  local input="$3"
  local envspec="$4"
  local expect_status="$5"
  local tag="$6"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  local out_h="$tmpdir/out_h"
  local err_h="$tmpdir/err_h"
  local st_h="$tmpdir/st_h"
  local out_r="$tmpdir/out_r"
  local err_r="$tmpdir/err_r"
  local st_r="$tmpdir/st_r"

  run_with_env "$hsh" "$input" "$envspec" "$out_h" "$err_h" "$st_h"
  run_with_env "$ref" "$input" "$envspec" "$out_r" "$err_r" "$st_r"

  local sh_status h_status
  h_status="$(cat "$st_h")"
  sh_status="$(cat "$st_r")"

  # If expect_status is set, enforce it for hsh. Otherwise compare to /bin/sh.
  if [[ -n "$expect_status" ]]; then
    if [[ "$h_status" != "$expect_status" ]]; then
      echo "Expected status=$expect_status, got $h_status"
      echo "--- stdout ---"; cat "$out_h"
      echo "--- stderr ---"; cat "$err_h"
      return 1
    fi
  else
    if [[ "$h_status" != "$sh_status" ]]; then
      echo "Status mismatch: hsh=$h_status sh=$sh_status"
      return 1
    fi
  fi

  # Compare stdout/stderr exactly
  if ! diff -u "$out_r" "$out_h"; then
    echo "STDOUT differs"
    return 1
  fi

  if ! diff -u "$err_r" "$err_h"; then
    echo "STDERR differs"
    return 1
  fi

  return 0
}

