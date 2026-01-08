#!/bin/bash
# Diff utilities for comparing outputs

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Compare two strings and show diff
show_diff() {
    local actual="$1"
    local expected="$2"
    local test_name="${3:-Test}"
    
    if [ "$actual" = "$expected" ]; then
        print_status "PASS" "$test_name"
        pass_test
        return 0
    else
        print_status "FAIL" "$test_name"
        fail_test
        
        echo "Expected:"
        echo "$expected" | sed 's/^/  /'
        echo "Actual:"
        echo "$actual" | sed 's/^/  /'
        
        # Show unified diff if diff command is available
        if command -v diff > /dev/null 2>&1; then
            echo "Diff:"
            diff -u <(echo "$expected") <(echo "$actual") | tail -n +3 | sed 's/^/  /'
        fi
        
        return 1
    fi
}

# Compare exit codes
compare_exit_codes() {
    local actual=$1
    local expected=$2
    local test_name="${3:-Exit code test}"
    
    if [ "$actual" -eq "$expected" ]; then
        print_status "PASS" "$test_name (exit code: $actual)"
        pass_test
        return 0
    else
        print_status "FAIL" "$test_name"
        fail_test
        echo "  Expected exit code: $expected"
        echo "  Actual exit code: $actual"
        return 1
    fi
}

# Compare outputs from shell vs system shell
compare_shell_output() {
    local cmd="$1"
    local test_name="${2:-Command output comparison}"
    
    # Run in our shell
    local our_output
    our_output=$(echo "$cmd" | "$SHELL_EXEC" 2>&1)
    local our_exit=$?
    
    # Run in system shell
    local sys_output
    sys_output=$(echo "$cmd" | /bin/sh 2>&1)
    local sys_exit=$?
    
    # Compare outputs
    if [ "$our_output" = "$sys_output" ] && [ "$our_exit" -eq "$sys_exit" ]; then
        print_status "PASS" "$test_name"
        pass_test
        return 0
    else
        print_status "FAIL" "$test_name"
        fail_test
        
        if [ "$our_output" != "$sys_output" ]; then
            echo "Output mismatch:"
            echo "System shell output:"
            echo "$sys_output" | sed 's/^/  /'
            echo "Our shell output:"
            echo "$our_output" | sed 's/^/  /'
        fi
        
        if [ "$our_exit" -ne "$sys_exit" ]; then
            echo "Exit code mismatch:"
            echo "  System shell: $sys_exit"
            echo "  Our shell: $our_exit"
        fi
        
        return 1
    fi
}

# Compare file contents
compare_files() {
    local file1="$1"
    local file2="$2"
    local test_name="${3:-File comparison}"
    
    if ! [ -f "$file1" ]; then
        print_status "FAIL" "$test_name - file1 does not exist: $file1"
        fail_test
        return 1
    fi
    
    if ! [ -f "$file2" ]; then
        print_status "FAIL" "$test_name - file2 does not exist: $file2"
        fail_test
        return 1
    fi
    
    if cmp -s "$file1" "$file2"; then
        print_status "PASS" "$test_name"
        pass_test
        return 0
    else
        print_status "FAIL" "$test_name"
        fail_test
        
        if command -v diff > /dev/null 2>&1; then
            echo "Diff:"
            diff -u "$file1" "$file2" | sed 's/^/  /'
        fi
        
        return 1
    fi
}
