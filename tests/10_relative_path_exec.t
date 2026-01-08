#!/bin/bash
# Test: Relative path execution
# The shell should execute commands with relative paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"
source "$SCRIPT_DIR/../lib/diff.sh"

# Initialize test environment
init_test_env

# Test name
TEST_NAME="Relative path execution"

# Check if shell exists
if ! check_shell_exists; then
    exit 1
fi

# Create a simple executable script in temp directory
TEST_SCRIPT="$TMP_DIR/test_script.sh"
cat > "$TEST_SCRIPT" << 'EOF'
#!/bin/bash
echo "relative path works"
EOF
chmod +x "$TEST_SCRIPT"

# Change to temp directory
cd "$TMP_DIR" || exit 1

# Run script with relative path
OUR_OUTPUT=$(echo "./test_script.sh" | "$SHELL_EXEC" 2>&1)
OUR_EXIT=$?

# Check exit code
if [ "$OUR_EXIT" -eq 0 ]; then
    print_status "PASS" "$TEST_NAME - exit code: $OUR_EXIT"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - unexpected exit code: $OUR_EXIT"
    fail_test
fi

# Check output
if echo "$OUR_OUTPUT" | grep -q "relative path works"; then
    print_status "PASS" "$TEST_NAME - correct output"
    pass_test
else
    print_status "FAIL" "$TEST_NAME - incorrect output"
    fail_test
    echo "  Expected: relative path works"
    echo "  Got: $OUR_OUTPUT"
fi

# Cleanup
cleanup_test_env

# Exit with appropriate code
if [ "$TESTS_FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
