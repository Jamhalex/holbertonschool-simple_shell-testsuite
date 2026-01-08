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

print_header

# stable ordering
mapfile -t test_files < <(find "$TESTS_DIR" -maxdepth 1 -type f | sort)

if [[ ${#test_files[@]} -eq 0 ]]; then
  echo "ERROR: No tests found in $TESTS_DIR"
  exit 2
fi

for tf in "${test_files[@]}"; do
  bn="$(basename "$tf")"

  if [[ "$bn" == *.skip ]]; then
    echo "SKIP  $bn (marked .skip)"
    ((skip++))
    continue
  fi

  ((total++))

  t_name="$(t_get "$tf" name)"
  t_input="$(t_get "$tf" input)"
  t_env="$(t_get "$tf" env)"
  t_expect_status="$(t_get "$tf" expect_status)"
  t_expect_stdout="$(t_get "$tf" expect_stdout)"
  t_expect_stderr="$(t_get "$tf" expect_stderr)"
  t_notes="$(t_get "$tf" notes)"

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
    ((pass++))
  else
    echo "FAIL  $bn"
    ((fail++))
  fi
  echo
done

echo "Summary"
echo "────────────────────────────────────────────────────────"
echo "TOTAL=$total  PASS=$pass  FAIL=$fail  SKIP=$skip"

# exit non-zero if any fail (good for CI)
[[ $fail -eq 0 ]]

