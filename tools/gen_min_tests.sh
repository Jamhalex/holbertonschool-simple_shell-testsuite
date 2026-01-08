#!/usr/bin/env bash
set -euo pipefail

# Purpose: Create a minimal-but-solid set of .t tests to cover tasks 0–20 quickly.
# Usage:   ./tools/gen_min_tests.sh
# Notes:   Won't overwrite existing tests unless you pass --force.

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$ROOT_DIR/tests"

mkdir -p "$TESTS_DIR"

# Helper: write file only if missing, unless --force.
write_file() {
  local path="$1"
  shift
  if [[ -f "$path" && "$FORCE" -ne 1 ]]; then
    echo "SKIP (exists) $path"
    return 0
  fi
  cat > "$path" <<'EOF'
__CONTENT__
EOF
  # Replace placeholder with actual content (passed via stdin)
}

# Helper: safe overwrite with content provided as heredoc
put() {
  local path="$1"
  shift
  if [[ -f "$path" && "$FORCE" -ne 1 ]]; then
    echo "SKIP (exists) $path"
    return 0
  fi
  cat > "$path"
  echo "WROTE        $path"
}

# 00 interactive prompt (kept .skip to avoid hangs in CI)
put "$TESTS_DIR/00_prompt_interactive.skip" <<'EOF'
name=interactive prompt exists (skipped)
notes=Interactive tests can hang automation; keep as .skip for manual runs.
input=
env=default
EOF

# 01: non-interactive basic command
put "$TESTS_DIR/01_non_interactive_ls.t" <<'EOF'
name=Non-interactive /bin/ls
input=ls\nexit\n
env=default
expect_status=
expect_stdout=
expect_stderr=
EOF

# 02: absolute path exec
put "$TESTS_DIR/02_absolute_path_exec.t" <<'EOF'
name=Absolute path command runs
input=/bin/ls\nexit\n
env=default
expect_status=
expect_stdout=
expect_stderr=
EOF

# 03: command not found -> 127
put "$TESTS_DIR/03_cmd_not_found_127.t" <<'EOF'
name=Command not found returns 127
input=nosuchcommand\nexit\n
env=default
expect_status=127
expect_stdout=
expect_stderr=
EOF

# 04: PATH empty -> not found -> 127
put "$TESTS_DIR/04_path_empty_127.t" <<'EOF'
name=Empty PATH -> ls not found -> 127
input=ls\nexit\n
env=PATH=
expect_status=127
expect_stdout=
expect_stderr=
EOF

# 05: minimal PATH still works
put "$TESTS_DIR/05_path_minimal_ok.t" <<'EOF'
name=Minimal PATH resolves ls
input=ls\nexit\n
env=PATH=/bin:/usr/bin
expect_status=
expect_stdout=
expect_stderr=
EOF

# 06: exit no arg uses last status (use a failing command)
put "$TESTS_DIR/06_exit_no_arg_uses_last_status.t" <<'EOF'
name=exit uses last command status
input=nosuchcommand\nexit\n
env=default
expect_status=127
expect_stdout=
expect_stderr=
EOF

# 07: exit with explicit status
put "$TESTS_DIR/07_exit_with_status_42.t" <<'EOF'
name=exit 42 exits with 42
input=exit 42\n
env=default
expect_status=42
expect_stdout=
expect_stderr=
EOF

# 08: env builtin (order independent)
put "$TESTS_DIR/08_env_builtin.t" <<'EOF'
name=env builtin prints environment
notes=Order is not guaranteed; stdout is compared sorted.
input=env\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
sort_stdout=1
EOF

# 09: cd builtin + pwd (covers cd behavior)
put "$TESTS_DIR/09_cd_root_then_pwd.t" <<'EOF'
name=cd builtin changes directory (cd / then pwd)
input=cd /\npwd\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
EOF

# 10: setenv then env (order independent)
put "$TESTS_DIR/10_setenv_then_env.t" <<'EOF'
name=setenv adds variable to environment
notes=We sort env output; _= is ignored by diff normalization.
input=setenv FOOBAR hello\nenv\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
sort_stdout=1
EOF

# 11: unsetenv then env
put "$TESTS_DIR/11_unsetenv_then_env.t" <<'EOF'
name=unsetenv removes variable from environment
input=setenv FOOBAR hello\nunsetenv FOOBAR\nenv\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
sort_stdout=1
EOF

# 12: comment line only (robustness / optional feature)
put "$TESTS_DIR/12_comment_ignored.t" <<'EOF'
name=comment-only line should do nothing
notes=Even if comments aren't implemented, shell must not crash.
input=# just a comment\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
EOF

# 13: ctrl-d / EOF exits cleanly
# Empty input file simulates immediate EOF
put "$TESTS_DIR/13_ctrl_d_exit.t" <<'EOF'
name=EOF (ctrl-d) exits cleanly
notes=Empty input simulates ctrl-d in non-interactive mode.
input=
env=default
expect_status=0
expect_stdout=
expect_stderr=
EOF

# 14: many empty lines then exit (loop stability)
put "$TESTS_DIR/14_many_empty_lines.t" <<'EOF'
name=many empty lines should not crash
input=\n\n\n\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
EOF

# 15: long command line (robustness)
# We'll generate a long argument string safely here
LONG="$(printf 'A%.0s' {1..2000})"
FILE15="$TESTS_DIR/15_long_command_line.t"
if [[ -f "$FILE15" && "$FORCE" -ne 1 ]]; then
  echo "SKIP (exists) $FILE15"
else
  {
    echo "name=long command line should not crash"
    echo "notes=Stress test for input parsing; should behave like /bin/sh."
    echo -n "input=echo $LONG\nexit\n"
    echo
    echo "env=default"
    echo "expect_status=0"
    echo "expect_stdout="
    echo "expect_stderr="
  } > "$FILE15"
  echo "WROTE        $FILE15"
fi

echo
echo "Done. Created minimal tests in: $TESTS_DIR"
echo "Tip: run -> HSH=/path/to/hsh ./checker.bash"
echo "Tip: rerun with --force to overwrite existing files."

