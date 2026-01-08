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
# Simple Shell Test Suite (Holberton)

Small, focused test suite for the Holberton **simple_shell** project.

It runs your `hsh` binary against a reference shell (`/bin/sh`) and compares:
- exit status
- stdout
- stderr (normalized so harmless differences don’t fail tests)

## Requirements

- Bash (scripts use `bash` + strict mode)
- `diff`, `find`, `sort`, `mktemp`
- Your compiled shell binary: `hsh`

## Quick start

From this repo root:

```bash
HSH=/full/path/to/your/hsh ./checker.bash

Example:

HSH=/home/rootera/Holberton/holbertonschool-simple_shell/hsh ./checker.bash
Contributing
This is a shared class repository.

Optional:

Change reference shell (default: /bin/sh)

REF=/bin/sh HSH=/full/path/to/hsh ./checker.bash


Verbose output (prints stdout/stderr even on PASS)

VERBOSE=1 HSH=/full/path/to/hsh ./checker.bash

How it works

Tests live in tests/

checker.bash runs each test file in stable order

For each test:

runs REF and HSH with the same input/environment

compares outputs using helpers in lib/

.skip tests are ignored (example: interactive prompt checks)

Test format (.t files)

Each test is a plain text file with key=value pairs.

Supported keys:

name — human readable name (optional)

notes — extra notes printed by checker (optional)

input — stdin to feed the shell (use \n for newlines)

env — environment spec

default (inherit environment)

or KEY=VAL;KEY2=VAL2 (runs with env -i plus these vars)

expect_status — expected exit status (optional)

if omitted, checker expects same status as REF

expect_stdout — expected stdout literal (optional; supports \n)

if omitted, checker compares stdout to REF

expect_stderr — expected stderr literal (optional; supports \n)

if omitted, checker compares stderr to REF (normalized)

sort_stdout — 1 to compare stdout order-independently (optional)

useful for env output

Notes on comparisons

stderr is normalized to avoid failing on harmless differences like
different program names in error messages.

For env-like outputs, set sort_stdout=1 (and _= is ignored).

Adding a new test

Create a new file in tests/ with a clear numeric prefix:

touch tests/11_my_new_test.t


Add keys. Example below.

Run the suite again:

HSH=/full/path/to/hsh ./checker.bash

Example test

tests/11_pwd_builtin.t:

name=pwd prints current directory
notes=Basic builtin output should match /bin/sh
input=pwd\nexit\n
env=default
expect_status=0


This test:

feeds pwd + exit to both shells

expects exit status 0

compares stdout/stderr to /bin/sh behavior

Skip a test

Rename it to end with .skip:

mv tests/00_prompt_interactive.t tests/00_prompt_interactive.skip

Project layout
.
├── checker.bash
├── lib/
│   ├── common.sh
│   └── diff.sh
└── tests/
    ├── 00_prompt_interactive.skip
    ├── 01_non_interactive_ls.t
    └── ...

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
