# Style Guide

## Shell Script Style

This test suite follows standard bash scripting conventions:

### File Naming
- Test files use `.t` extension
- Test files are numbered sequentially (00_, 01_, etc.)
- Descriptive names after the number (e.g., `01_non_interactive_ls.t`)
- Skip files use `.skip` extension for tests that should not run

### Code Style
- Use 4 spaces for indentation (no tabs)
- Functions should have descriptive names
- Use meaningful variable names
- Add comments for complex logic
- Always quote variables to prevent word splitting
- Use `$()` for command substitution instead of backticks

### Test Structure
- Each test file should be self-contained
- Tests should clean up after themselves
- Use the common library functions from `lib/common.sh`
- Tests should check exit codes and output
- Error messages should be descriptive

### Best Practices
- Always check if required commands exist
- Handle edge cases (empty input, special characters)
- Test both success and failure scenarios
- Keep tests focused and simple
- Document any special requirements or dependencies

## Writing New Tests

When adding new tests:
1. Choose an appropriate sequential number
2. Use descriptive name after the number
3. Follow the existing test format
4. Test one specific feature or behavior
5. Include both positive and negative test cases
6. Document what the test is checking
