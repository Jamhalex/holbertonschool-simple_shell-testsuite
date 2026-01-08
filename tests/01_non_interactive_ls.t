#!/bin/bash
# Test: Non-interactive ls command
# The shell should execute 'ls' command in non-interactive mode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Non-interactive ls command"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run ls in our shell
OUR_OUTPUT=$(echo "ls" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Run ls in system shell for comparison
SYS_OUTPUT=$(echo "ls" | /bin/sh 2>&1)
SYS_EXIT=$?

# Check exit code
if [ "$OUR_EXIT" -eq "$SYS_EXIT" ] && [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - exit code mismatch"
    fail_test
    echo "  Expected: $SYS_EXIT"
    echo "  Got: $OUR_EXIT"
fi

# Note: Output comparison is tricky because ls output can vary by directory
# We just check that some output was produced
if [ -n "$OUR_OUTPUT" ]; then
    print_status "PASS" "$TEST_NAME - output produced"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - no output produced"
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
