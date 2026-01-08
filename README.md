# Simple Shell – Shared Test Suite

This repository contains a **community-driven test suite** for the
Holberton School **Simple Shell** project (tasks 0–20).

The goal of this project is to provide **one shared reference test suite**
that validates student shells by comparing their behavior against
`/bin/sh`, covering both **regular cases** and **edge cases**.

This repository is intended to be used and improved collaboratively
by the entire cohort.

---

## Purpose

Writing a shell is easy to get *mostly* right and still fail subtle cases.

This test suite exists to:
- Catch incorrect exit statuses (e.g. `127` for command not found)
- Detect PATH resolution bugs
- Validate non-interactive behavior
- Ensure correct handling of empty input
- Verify builtin behavior (`exit`, `env`)
- Compare output and errors against `/bin/sh`

If a test fails here, it is very likely to fail the checker.

---

## Repository Structure

holbertonschool-simple_shell-testsuite/
├─ checker.bash # Main test runner
├─ lib/ # Shared helpers
│ ├─ common.sh
│ └─ diff.sh
├─ tests/ # Individual test cases (*.t)
├─ fixtures/ # Input scripts / helper files
├─ README.md
├─ AUTHORS
├─ LICENSE
└─ style.md


---

## How to Run the Test Suite

First, build your shell:

```bash
gcc -Wall -Werror -Wextra -pedantic -std=gnu89 *.c -o hsh
Then run the test suite from this repository:

bash
Copy code
HSH=/full/path/to/your/hsh ./checker.bash
By default:

Your shell (hsh) is compared against /bin/sh

Output, error output, and exit status are checked

Optional flags:

bash
Copy code
REF=/bin/sh        # Change reference shell (advanced)
VERBOSE=1          # Print stdout/stderr even on pass
Test Format
Each test is a plain text file in tests/ using a simple key-value format:

ini
Copy code
name=Command not found returns 127
input=nosuchcommand\n
env=default
expect_status=127
Supported keys include:

name

input

env

expect_status

expect_stdout

expect_stderr

notes

Tests marked with .skip are intentionally skipped
(e.g. interactive-only behavior).

Contributing
This is a shared class repository.

To contribute:

Add one or more meaningful tests in tests/

Ensure tests cover real behavior or edge cases

Follow the existing test style

Add your name to AUTHORS

Submit a pull request

Fixing typos alone is not considered a valid contribution unless it
fixes a real bug.

Style
Tests should be small and focused

Prefer behavior comparison against /bin/sh

Document edge cases using the notes= field

Be consistent with naming and formatting

See style.md for details.

Authors
See the AUTHORS file for the list of contributors.
