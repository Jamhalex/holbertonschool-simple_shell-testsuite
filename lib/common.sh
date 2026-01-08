#!/bin/bash
# Common functions for test suite

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Shell executable path (can be overridden)
SHELL_EXEC="${SHELL_EXEC:-./hsh}"

# Temporary files directory
TMP_DIR="${TMP_DIR:-/tmp/shell_tests_$$}"

# Initialize test environment
init_test_env() {
    mkdir -p "$TMP_DIR"
    export PATH_ORIG="$PATH"
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "$TMP_DIR"
    export PATH="$PATH_ORIG"
}

# Print colored message
print_status() {
    local status=$1
    local message=$2
    
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} $message"
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}[FAIL]${NC} $message"
    elif [ "$status" = "SKIP" ]; then
        echo -e "${YELLOW}[SKIP]${NC} $message"
    elif [ "$status" = "INFO" ]; then
        echo -e "${YELLOW}[INFO]${NC} $message"
    fi
}

# Check if shell executable exists
check_shell_exists() {
    if [ ! -x "$SHELL_EXEC" ]; then
        print_status "FAIL" "Shell executable not found: $SHELL_EXEC"
        return 1
    fi
    return 0
}

# Run command in shell and capture output
run_shell_cmd() {
    local cmd="$1"
    local input_file="${2:-/dev/null}"
    
    if [ -f "$input_file" ]; then
        echo "$cmd" | "$SHELL_EXEC" < "$input_file" 2>&1
    else
        echo "$cmd" | "$SHELL_EXEC" 2>&1
    fi
}

# Run command in shell non-interactively
run_shell_noninteractive() {
    local cmd="$1"
    echo "$cmd" | "$SHELL_EXEC" 2>&1
}

# Compare output with expected
compare_output() {
    local actual="$1"
    local expected="$2"
    
    if [ "$actual" = "$expected" ]; then
        return 0
    else
        return 1
    fi
}

# Check exit status
check_exit_status() {
    local actual=$1
    local expected=$2
    
    if [ "$actual" -eq "$expected" ]; then
        return 0
    else
        return 1
    fi
}

# Increment test counters
pass_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Print test summary
print_summary() {
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Total tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo "================================"
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Create temporary file
create_temp_file() {
    mktemp "$TMP_DIR/tmp.XXXXXX"
}

# Execute shell command and get exit code
exec_shell_get_exitcode() {
    local cmd="$1"
    echo "$cmd" | "$SHELL_EXEC" > /dev/null 2>&1
    echo $?
}

# Execute regular command and get exit code (for comparison)
exec_cmd_get_exitcode() {
    local cmd="$1"
    eval "$cmd" > /dev/null 2>&1
    echo $?
}

# Strip trailing newlines for comparison
strip_trailing_newlines() {
    local str="$1"
    echo -n "$str"
}
