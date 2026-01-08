#!/bin/bash
# Test: exit without argument uses last status
# The 'exit' builtin without arguments should use the last command's exit status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="exit without argument uses last status"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Test: Last command succeeded (exit 0), then exit
printf "/bin/true\nexit\n" | "$SHELL_EXEC" 2>&1
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 0 "$TEST_NAME (after successful command)"

# Test: Last command failed (exit 1), then exit
printf "/bin/false\nexit\n" | "$SHELL_EXEC" 2>&1
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 1 "$TEST_NAME (after failed command)"

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
