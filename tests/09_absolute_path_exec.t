#!/bin/bash
# Test: Absolute path execution
# The shell should execute commands with absolute paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Absolute path execution"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run command with absolute path in our shell
OUR_OUTPUT=$(echo "/bin/ls" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Check exit code
if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME (/bin/ls) - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME (/bin/ls) - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Test with /bin/echo
OUR_OUTPUT=$(echo "/bin/echo hello" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME (/bin/echo) - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME (/bin/echo) - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Check output
if echo "$OUR_OUTPUT" | grep -q "hello"; then
    print_status "PASS" "$TEST_NAME - output contains 'hello'"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - output does not contain 'hello'"
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
