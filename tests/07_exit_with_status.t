#!/bin/bash
# Test: exit with status argument
# The 'exit' builtin with an argument should use that status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="exit with status argument"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Test: exit 0
echo "exit 0" | "$SHELL_EXEC" 2>&1
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 0 "$TEST_NAME (exit 0)"

# Test: exit 5
echo "exit 5" | "$SHELL_EXEC" 2>&1
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 5 "$TEST_NAME (exit 5)"

# Test: exit 127
echo "exit 127" | "$SHELL_EXEC" 2>&1
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 127 "$TEST_NAME (exit 127)"

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
