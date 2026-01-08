#!/bin/bash
# Main test runner for simple shell test suite

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions
source "$SCRIPT_DIR/lib/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test statistics
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -s, --shell PATH     Path to shell executable (default: ./hsh)"
    echo "  -t, --test TEST      Run specific test file"
    echo "  -v, --verbose        Verbose output"
    echo "  -q, --quiet          Quiet mode (only show summary)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tests"
    echo "  $0 -s ./my_shell            # Test custom shell"
    echo "  $0 -t tests/01_*.t          # Run specific tests"
    echo ""
}

# Parse command line arguments
VERBOSE=0
QUIET=0
TEST_PATTERN=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -s|--shell)
            SHELL_EXEC="$2"
            shift 2
            ;;
        -t|--test)
            TEST_PATTERN="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -q|--quiet)
            QUIET=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Export shell path for tests
export SHELL_EXEC="${SHELL_EXEC:-./hsh}"

# Print banner
if [ "$QUIET" -eq 0 ]; then
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Simple Shell Test Suite${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "Shell: $SHELL_EXEC"
    echo ""
fi

# Check if shell exists
if [ ! -f "$SHELL_EXEC" ]; then
    echo -e "${RED}Error: Shell executable not found: $SHELL_EXEC${NC}"
    echo "Please compile your shell or specify path with -s option"
    exit 1
fi

if [ ! -x "$SHELL_EXEC" ]; then
    echo -e "${YELLOW}Warning: Shell is not executable, attempting to make it executable${NC}"
    chmod +x "$SHELL_EXEC"
    if [ ! -x "$SHELL_EXEC" ]; then
        echo -e "${RED}Error: Cannot make shell executable${NC}"
        exit 1
    fi
fi

# Find test files
if [ -n "$TEST_PATTERN" ]; then
    # Use specified pattern
    TEST_FILES=$(find "$SCRIPT_DIR/tests" -name "$TEST_PATTERN" -type f 2>/dev/null | sort)
else
    # Find all .t files, excluding .skip files
    TEST_FILES=$(find "$SCRIPT_DIR/tests" -name "*.t" -type f 2>/dev/null | sort)
fi

# Check if any tests were found
if [ -z "$TEST_FILES" ]; then
    echo -e "${YELLOW}No test files found${NC}"
    exit 0
fi

# Run tests
for test_file in $TEST_FILES; do
    test_name=$(basename "$test_file")
    
    # Skip if corresponding .skip file exists
    skip_file="${test_file%.t}.skip"
    if [ -f "$skip_file" ]; then
        if [ "$QUIET" -eq 0 ]; then
            echo -e "${YELLOW}[SKIP]${NC} $test_name"
        fi
        SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
        continue
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$QUIET" -eq 0 ]; then
        echo -e "${BLUE}Running:${NC} $test_name"
    fi
    
    # Make test executable if needed
    if [ ! -x "$test_file" ]; then
        chmod +x "$test_file"
    fi
    
    # Run the test
    if [ "$VERBOSE" -eq 1 ]; then
        bash "$test_file"
        test_result=$?
    else
        test_output=$(bash "$test_file" 2>&1)
        test_result=$?
    fi
    
    # Check result
    if [ $test_result -eq 0 ]; then
        if [ "$QUIET" -eq 0 ]; then
            if [ "$VERBOSE" -eq 0 ]; then
                echo -e "  ${GREEN}✓ PASSED${NC}"
            fi
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        if [ "$QUIET" -eq 0 ]; then
            echo -e "  ${RED}✗ FAILED${NC}"
            if [ "$VERBOSE" -eq 0 ]; then
                echo "$test_output" | sed 's/^/    /'
            fi
        fi
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    if [ "$QUIET" -eq 0 ]; then
        echo ""
    fi
done

# Print summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
if [ "$SKIPPED_TESTS" -gt 0 ]; then
    echo -e "${YELLOW}Skipped: $SKIPPED_TESTS${NC}"
fi
echo -e "${BLUE}================================${NC}"

# Calculate success rate
if [ "$TOTAL_TESTS" -gt 0 ]; then
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Success rate: ${success_rate}%"
fi

echo ""

# Exit with appropriate code
if [ "$FAILED_TESTS" -eq 0 ] && [ "$TOTAL_TESTS" -gt 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
elif [ "$TOTAL_TESTS" -eq 0 ]; then
    echo -e "${YELLOW}No tests were run${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi
