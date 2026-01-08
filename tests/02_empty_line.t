#!/bin/bash
# Test: Empty line handling
# The shell should handle empty lines gracefully (just display prompt again)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Empty line handling"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run empty line in our shell
OUR_OUTPUT=$(echo "" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Shell should not crash and should exit cleanly
if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Output should be empty or just contain prompt
# (We don't check output content as it may vary with prompt implementation)

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
