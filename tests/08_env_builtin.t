#!/bin/bash
# Test: env builtin
# The 'env' builtin should print the environment variables

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="env builtin"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run env in our shell
OUR_OUTPUT=$(echo "env" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Check exit code
if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Check that some environment variables are in output
if echo "$OUR_OUTPUT" | grep -q "PATH="; then
    print_status "PASS" "$TEST_NAME - PATH found in output"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - PATH not found in output"
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
