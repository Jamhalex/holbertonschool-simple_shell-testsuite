# Simple Shell Test Suite

A small and practical test suite for the **Holberton simple_shell project**.

This repository helps you automatically test your `hsh` binary by comparing its behavior against `/bin/sh`.

It checks:
- exit status
- stdout
- stderr (normalized to avoid false failures)

If your shell behaves like `/bin/sh`, the test passes.

---

## Requirements

- Linux
- Bash
- Standard tools: `diff`, `sort`, `find`, `mktemp`
- A compiled **simple_shell binary** (`hsh`)

---

## How to run the tests (Quick Start)

From the root of this repository:

```bash
HSH=/full/path/to/your/hsh ./checker.bash
Example:

bash
Copy code
HSH=/home/user/holbertonschool-simple_shell/hsh ./checker.bash
Optional options
Run with verbose output (prints stdout/stderr even on PASS):

bash
Copy code
VERBOSE=1 HSH=/path/to/hsh ./checker.bash
Use a different reference shell (default is /bin/sh):

bash
Copy code
REF=/bin/sh HSH=/path/to/hsh ./checker.bash
How this test suite works
Each test lives in the tests/ directory.

For every test:

The same input is sent to /bin/sh and to your hsh.

Exit status, stdout, and stderr are compared.

Harmless differences are ignored:

stderr program name differences

environment order differences

A final summary is printed.

Test files (.t format)
Each test is a plain text file with key=value pairs.

Supported keys
Key	Description
name	Human-readable test name
notes	Extra explanation printed during the run
input	Commands sent to stdin (\n = newline)
env	Environment for the test
expect_status	Expected exit code
expect_stdout	Expected stdout (optional)
expect_stderr	Expected stderr (optional)
sort_stdout	Set to 1 if output order doesn’t matter

Environment (env)
default → inherit current environment

KEY=VAL;KEY2=VAL2 → run with env -i and only these variables

Example test
Create a new test file:

bash
Copy code
tests/11_pwd_builtin.t
Content:

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

Compares output with /bin/sh

Order-independent output (env example)
Some commands (like env) do not guarantee output order.

For those tests, add:

ini
Copy code
sort_stdout=1
The test suite will:

sort output before comparing

ignore the _= variable (which differs between shells)

Skipping a test
To temporarily disable a test, rename it with .skip:

bash
Copy code
mv tests/00_prompt_interactive.t tests/00_prompt_interactive.skip
Skipped tests are reported but not executed.

Project structure
bash
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

Purpose
This test suite is meant to:

catch real bugs in your shell

avoid false negatives

be easy to extend and understand


> ⚠️ **Important:** Tests for `setenv` and `unsetenv` do **not** compare against `/bin/sh`.  
> `/bin/sh` does not implement these builtins, and doing a reference diff would yield **incorrect failures**.  
> These tests therefore use **explicit assertions** on expected output.

Designed for Holberton peer review and cohort usage.
