#!/usr/bin/env bash
set -euo pipefail

SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"
TESTS_DIR="$SUITE_DIR/tests"
LIB_DIR="$SUITE_DIR/lib"

# Target student shell binary (must be executable)
HSH="${HSH:-./hsh}"

# Reference shell binary (oracle). Holberton expects /bin/sh behavior.
REF="${REF:-/bin/sh}"

source "$LIB_DIR/common.sh"
source "$LIB_DIR/diff.sh"

usage() {
  cat << EOF
Usage:
  HSH=/path/to/hsh ./checker.bash
Options:
  REF=/bin/sh (default)
  VERBOSE=1   (print stdout/stderr even on pass)
Examples:
  HSH=../holbertonschool-simple_shell/hsh ./checker.bash
  HSH=./hsh REF=/bin/sh VERBOSE=1 ./checker.bash
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ ! -x "$HSH" ]]; then
  echo "ERROR: HSH not executable: $HSH"
  echo "Tip: build your shell, then run:"
  echo "  HSH=/full/path/to/hsh ./checker.bash"
  exit 2
fi

if [[ ! -x "$REF" ]]; then
  echo "ERROR: REF not executable: $REF"
  exit 2
fi

pass=0
fail=0
skip=0
total=0

print_header() {
  echo "Simple Shell Test Suite"
  echo "────────────────────────────────────────────────────────"
  echo "HSH: $HSH"
  echo "REF: $REF"
  echo
}

# --------------------------------------------------------------------
# Fallback runner: define run_test if common.sh doesn't provide it
# --------------------------------------------------------------------
if ! declare -F run_test >/dev/null 2>&1; then
  run_test() {
    local hsh="$1"
    local ref="$2"
    local t_input="$3"
    local t_env="$4"
    local t_expect_status="$5"
    local t_expect_stdout="$6"
    local t_expect_stderr="$7"
    local bn="$8"

    local tmp
    tmp="$(mktemp -d)"
    local in_file="$tmp/in.txt"
    local out_r="$tmp/out_r"
    local err_r="$tmp/err_r"
    local out_h="$tmp/out_h"
    local err_h="$tmp/err_h"
    local st_r=0
    local st_h=0

    # input is stored with \n escapes in .t files
    printf '%b' "$t_input" > "$in_file"

    # Build environment prefix
    # - "default" => inherit
    # - otherwise: env -i + envspec exports + kill startup noise
    local prefix=""
    if [[ -n "$t_env" && "$t_env" != "default" ]]; then
      # envspec_to_exports is defined in common.sh
      prefix="env -i $(envspec_to_exports "$t_env") ENV=/dev/null BASH_ENV=/dev/null "
    fi

    # Run reference
    # shellcheck disable=SC2086
    set +e
    eval ${prefix}"\"$ref\" < \"$in_file\" > \"$out_r\" 2> \"$err_r\""
    st_r=$?
    set -e

    # Run student
    # shellcheck disable=SC2086
    set +e
    eval ${prefix}"\"$hsh\" < \"$in_file\" > \"$out_h\" 2> \"$err_h\""
    st_h=$?
    set -e

    # Status check
    if [[ -n "${t_expect_status:-}" ]]; then
      if [[ "$st_h" -ne "$t_expect_status" ]]; then
        echo "Exit status differs (expected=$t_expect_status got=$st_h)"
        rm -rf "$tmp"
        return 1
      fi
    else
      if [[ "$st_h" -ne "$st_r" ]]; then
        echo "Exit status differs (ref=$st_r hsh=$st_h)"
        rm -rf "$tmp"
        return 1
      fi
    fi

    # Output expectations:
    # - If expect_stdout/stderr are empty => compare to REF
    # - If provided => compare to literal expected content
    if [[ -n "${t_expect_stdout:-}" ]]; then
      local exp_out="$tmp/exp_out"
      printf '%b' "$t_expect_stdout" > "$exp_out"
      if ! diff_stdout "$exp_out" "$out_h"; then
        echo "STDOUT differs"
        rm -rf "$tmp"
        return 1
      fi
    else
      if ! compare_out_err "$out_r" "$out_h" "$err_r" "$err_h"; then
        rm -rf "$tmp"
        return 1
      fi
    fi

    if [[ -n "${t_expect_stderr:-}" ]]; then
      local exp_err="$tmp/exp_err"
      printf '%b' "$t_expect_stderr" > "$exp_err"
      if ! diff_stderr "$exp_err" "$err_h"; then
        echo "STDERR differs"
        rm -rf "$tmp"
        return 1
      fi
    fi

    if [[ "${VERBOSE:-0}" == "1" ]]; then
      echo "---- STDOUT (ref) ----"; cat "$out_r" || true
      echo "---- STDERR (ref) ----"; cat "$err_r" || true
      echo "---- STDOUT (hsh) ----"; cat "$out_h" || true
      echo "---- STDERR (hsh) ----"; cat "$err_h" || true
    fi

    rm -rf "$tmp"
    return 0
  }
fi

# --------------------------------------------------------------------

print_header

mapfile -t test_files < <(find "$TESTS_DIR" -maxdepth 1 -type f | sort)

if [[ ${#test_files[@]} -eq 0 ]]; then
  echo "ERROR: No tests found in $TESTS_DIR"
  exit 2
fi

for tf in "${test_files[@]}"; do
  bn="$(basename "$tf")"

  if [[ "$bn" == *.skip ]]; then
    echo "SKIP  $bn (marked .skip)"
    ((++skip))
    continue
  fi

  ((++total))

  t_name="$(t_get "$tf" name)"
  t_input="$(t_get "$tf" input)"
  t_env="$(t_get "$tf" env)"
  t_expect_status="$(t_get "$tf" expect_status)"
  t_expect_stdout="$(t_get "$tf" expect_stdout)"
  t_expect_stderr="$(t_get "$tf" expect_stderr)"
  t_notes="$(t_get "$tf" notes)"

  # NEW: per-test stdout normalization toggle (for env, etc.)
  t_sort_stdout="$(t_get "$tf" sort_stdout)"
  [[ -z "$t_sort_stdout" ]] && t_sort_stdout="0"
  export SORT_STDOUT="$t_sort_stdout"

  # defaults
  [[ -z "$t_name" ]] && t_name="$bn"
  [[ -z "$t_env" ]] && t_env="default"

  echo "RUN   $bn — $t_name"
  [[ -n "$t_notes" ]] && echo "      note: $t_notes"

  if run_test \
      "$HSH" "$REF" \
      "$t_input" "$t_env" \
      "$t_expect_status" \
      "$t_expect_stdout" "$t_expect_stderr" \
      "$bn"; then
    echo "PASS  $bn"
    ((++pass))
  else
    echo "FAIL  $bn"
    ((++fail))
  fi

  export SORT_STDOUT="0"
  echo
done

echo "Summary"
echo "────────────────────────────────────────────────────────"
echo "TOTAL=$total  PASS=$pass  FAIL=$fail  SKIP=$skip"

[[ $fail -eq 0 ]]

