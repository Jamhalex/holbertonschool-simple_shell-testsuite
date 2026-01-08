#!/bin/bash
# Test: Spaces only line handling
# The shell should handle lines with only spaces gracefully

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Spaces only line handling"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run line with spaces in our shell
OUR_OUTPUT=$(echo "   " | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Shell should not crash and should exit cleanly
if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Test with tabs
OUR_OUTPUT=$(echo "	" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME (tabs) - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME (tabs) - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
