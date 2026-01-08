# holbertonschool-simple_shell-testsuite

SIMPLE SHELL TEST FOR EVERYONE TO USE

## Description

This is a comprehensive test suite for testing simple shell implementations, specifically designed for Holberton School simple shell projects. The test suite validates various aspects of shell functionality including command execution, built-in commands, error handling, and exit status codes.

## Features

- **Automated Testing**: Run all tests with a single command
- **Modular Design**: Individual test files for specific functionality
- **Detailed Output**: Clear pass/fail indicators with detailed error messages
- **Flexible Configuration**: Specify custom shell paths and test patterns
- **Common Utilities**: Reusable functions for consistent testing
- **Skip Mechanism**: Tests can be skipped when not applicable

## Project Structure

```
holbertonschool-simple_shell-testsuite/
├── README.md           # This file
├── AUTHORS             # List of contributors
├── LICENSE             # MIT License
├── style.md            # Style guide for test suite
├── checker.bash        # Main test runner script
├── lib/                # Shared library functions
│   ├── common.sh       # Common test utilities
│   └── diff.sh         # Output comparison utilities
├── tests/              # Individual test files
│   ├── 00_prompt_interactive.skip
│   ├── 01_non_interactive_ls.t
│   ├── 02_empty_line.t
│   ├── 03_spaces_only.t
│   ├── 04_cmd_not_found_127.t
│   ├── 05_path_empty_127.t
│   ├── 06_exit_no_arg_uses_last_status.t
│   ├── 07_exit_with_status.t
│   ├── 08_env_builtin.t
│   ├── 09_absolute_path_exec.t
│   └── 10_relative_path_exec.t
└── fixtures/           # Test data and fixtures
```

## Requirements

- Bash shell (version 4.0 or higher)
- A simple shell executable to test (default: `./hsh`)
- Standard Unix utilities (ls, echo, etc.)

## Installation

Clone the repository:

```bash
git clone https://github.com/Jamhalex/holbertonschool-simple_shell-testsuite.git
cd holbertonschool-simple_shell-testsuite
```

Make the checker executable:

```bash
chmod +x checker.bash
```

## Usage

### Basic Usage

Place your compiled shell executable in the same directory and name it `hsh`, then run:

```bash
./checker.bash
```

### Specify Custom Shell Path

```bash
./checker.bash -s /path/to/your/shell
```

### Run Specific Tests

```bash
./checker.bash -t "tests/01_*.t"
```

### Verbose Output

```bash
./checker.bash -v
```

### Quiet Mode (Summary Only)

```bash
./checker.bash -q
```

### Help

```bash
./checker.bash -h
```

## Test Categories

### Basic Shell Tests

1. **00_prompt_interactive** (skipped): Tests interactive prompt display
2. **01_non_interactive_ls**: Tests non-interactive command execution
3. **02_empty_line**: Tests empty line handling
4. **03_spaces_only**: Tests lines with only whitespace

### Error Handling Tests

5. **04_cmd_not_found_127**: Verifies exit code 127 for non-existent commands
6. **05_path_empty_127**: Tests behavior with empty PATH

### Built-in Commands Tests

7. **06_exit_no_arg_uses_last_status**: Tests `exit` without arguments
8. **07_exit_with_status**: Tests `exit` with status argument
9. **08_env_builtin**: Tests `env` builtin command

### Path Execution Tests

10. **09_absolute_path_exec**: Tests absolute path command execution
11. **10_relative_path_exec**: Tests relative path command execution

## Writing New Tests

To add a new test:

1. Create a new file in the `tests/` directory following the naming convention: `XX_description.t`
2. Make the file executable: `chmod +x tests/XX_description.t`
3. Follow the template structure from existing tests
4. Source the common libraries:
   ```bash
   #!/bin/bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   source "$SCRIPT_DIR/../lib/common.sh"
   source "$SCRIPT_DIR/../lib/diff.sh"
   ```
5. Use the provided utility functions for consistency

See `style.md` for detailed style guidelines.

## Available Test Utilities

### From lib/common.sh

- `init_test_env()`: Initialize test environment
- `cleanup_test_env()`: Clean up test environment
- `check_shell_exists()`: Verify shell executable exists
- `run_shell_cmd()`: Run command in shell
- `compare_output()`: Compare actual vs expected output
- `check_exit_status()`: Check exit status codes
- `pass_test()`: Mark test as passed
- `fail_test()`: Mark test as failed
- `print_summary()`: Print test results summary

### From lib/diff.sh

- `show_diff()`: Compare and display differences
- `compare_exit_codes()`: Compare exit codes with detailed output
- `compare_shell_output()`: Compare shell output with system shell
- `compare_files()`: Compare file contents

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Follow the style guide in `style.md`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

See [AUTHORS](AUTHORS) file for list of contributors.

## Support

For issues, questions, or contributions, please open an issue on GitHub.

## Acknowledgments

- Holberton School for the simple shell project concept
- All contributors who help improve this test suite
