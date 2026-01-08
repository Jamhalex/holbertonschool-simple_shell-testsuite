#!/bin/bash
# Test: Command not found returns 127
# When a command is not found, the shell should return exit status 127

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Command not found returns 127"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Run non-existent command in our shell
OUR_OUTPUT=$(echo "/bin/notacommand" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Check exit code is 127
compare_exit_codes "$OUR_EXIT" 127 "$TEST_NAME"

# Test with another non-existent command
OUR_OUTPUT=$(echo "thiscommanddoesnotexist" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

compare_exit_codes "$OUR_EXIT" 127 "$TEST_NAME (alternative command)"

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
