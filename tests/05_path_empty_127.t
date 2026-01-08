#!/bin/bash
# Test: Empty PATH returns 127
# When PATH is empty and a command without path is given, should return 127

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Empty PATH returns 127"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run command with empty PATH
OUR_OUTPUT=$(echo "ls" | PATH="" "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Check exit code is 127
compare_exit_codes "$OUR_EXIT" 127 "$TEST_NAME"

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
