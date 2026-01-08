# Simple Shell Test Suite

A practical and deterministic test suite for the **Holberton `simple_shell` project**.

This repository allows you to automatically test your `hsh` binary by validating its behavior against `/bin/sh` **when applicable**, and through explicit assertions for project-specific features.

---

## What this test suite checks

- Exit status
- Standard output (stdout)
- Standard error (stderr), normalized to avoid false failures
- Environment handling
- Builtins behavior

If your shell behaves correctly, the tests pass.

---

## Requirements

- Linux
- Bash
- Standard tools: `diff`, `sort`, `find`, `mktemp`
- A compiled **simple_shell binary** (`hsh`)

---

## Quick Start

From the root of this repository:

```bash
HSH=/full/path/to/your/hsh ./checker.bash
Example:

bash
Copy code
HSH=/home/user/holbertonschool-simple_shell/hsh ./checker.bash
Optional flags:

Verbose output (print stdout/stderr even on PASS):

bash
Copy code
VERBOSE=1 HSH=/path/to/hsh ./checker.bash
Use a different reference shell (default is /bin/sh):

bash
Copy code
REF=/bin/sh HSH=/path/to/hsh ./checker.bash
How the test suite works
Each test lives in the tests/ directory.

For every test:

The same input is sent to /bin/sh and to hsh

Exit status, stdout, and stderr are compared

Harmless differences are ignored:

executable name differences in stderr

environment variable ordering

A summary is printed at the end.

Test file format (.t files)
Each test is a plain text file using key=value pairs.

Supported keys
Key	Description
name	Human-readable test name
notes	Optional explanation
input	Commands sent to stdin (\n = newline)
env	Environment configuration
expect_status	Expected exit status
expect_stdout	Expected stdout (optional)
expect_stderr	Expected stderr (optional)
sort_stdout	Set to 1 if output order doesn’t matter

Environment handling (env)
default → inherit current environment

KEY=VAL;KEY2=VAL2 → run with env -i and only these variables

Startup noise is eliminated using:

text
Copy code
ENV=/dev/null
Example test
File: tests/11_pwd_builtin.t

ini
Copy code
name=pwd prints current directory
notes=Basic builtin behavior
input=pwd\nexit\n
env=default
expect_status=0
What this test does:

Sends pwd to both shells

Expects exit code 0

Compares output against /bin/sh

Order-independent output (example: env)
Some commands (like env) do not guarantee output order.

For those tests, add:

ini
Copy code
sort_stdout=1
The test suite will:

Sort output before comparing

Ignore the _= variable (which differs between shells)

Skipping tests
To temporarily disable a test, rename it with .skip:

bash
Copy code
mv tests/00_prompt_interactive.t tests/00_prompt_interactive.skip
Skipped tests are reported but not executed.

Project structure
text
Copy code
.
├── checker.bash        # Main test runner
├── lib/
│   ├── common.sh       # Helpers (parsing, env handling)
│   └── diff.sh         # Output comparison logic
└── tests/
    ├── 00_prompt_interactive.skip
    ├── 01_non_interactive_ls.t
    ├── 02_empty_line.t
    └── ...
Exit status
0 → all tests passed

1 → at least one test failed

Useful for CI and automation.

Important note on non-POSIX builtins
⚠️ Important: Tests for setenv and unsetenv do not compare against /bin/sh.
/bin/sh does not implement these builtins, and doing a reference diff would yield incorrect failures.
These tests therefore use explicit assertions on expected behavior.

Designed for deterministic validation, fair peer review, and deep understanding of the Simple Shell project.
