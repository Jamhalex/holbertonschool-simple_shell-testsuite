TL;DR

This test suite validates a Simple Shell implementation by:

Comparing POSIX behavior against /bin/sh when applicable

Using explicit assertions for project-specific builtins (setenv, unsetenv)

Sanitizing stderr to avoid shell-name false negatives

Eliminating environment startup noise (ENV=/dev/null)

Providing deterministic, reproducible results suitable for peer review and grading

Audit Purpose

This document explains what was changed, why it was changed, and how those changes elevated the project from a fragile, low-signal checker to a deterministic and fair validation system.

It is written so that:

a teammate can audit the work,

a reviewer can understand design decisions,

and the project can be defended technically during presentation or evaluation.

Initial State (Before)

When the test suite was first executed, it suffered from multiple structural problems:

False negatives

/bin/sh and hsh printed different program names in stderr

Environment variable order caused spurious failures

Startup scripts (.profile, ENV) polluted output

Non-deterministic tests

env output was compared line-by-line without sorting

Tests depended on the user’s environment

Incorrect reference comparisons

setenv and unsetenv were compared against /bin/sh

/bin/sh does not implement these builtins, causing guaranteed failures

Missing behavioral coverage

Comment-only lines caused errors

Builtins were inconsistently validated

Exit status propagation was fragile

Result:
👉 A shell could be correct and still fail the checker.

Design Decisions & Fixes
1. STDERR Normalization

Implemented sanitize_stderr logic

Removed executable-name differences from error messages

Focused comparison on error meaning, not formatting

✅ Prevents false failures like:

/bin/sh: 1: ls: not found
hsh: 1: ls: not found

2. Environment Control

Introduced controlled execution via env -i

Disabled startup noise with:

ENV=/dev/null
BASH_ENV=/dev/null


✅ Ensures reproducibility across machines and users

3. Sorted Output for Non-Ordered Commands

Added sort_stdout=1 support

Applied to commands like env

✅ Prevents order-dependent failures

4. Explicit Assertions for Non-POSIX Builtins

setenv and unsetenv are project-specific, not POSIX.

Key decision:

Do not compare them against /bin/sh

Instead, assert their expected behavior

Example:

setenv FOOBAR hello

Validate via printenv FOOBAR

✅ Avoids invalid reference comparisons
✅ Accurately tests project requirements

5. Shell Loop Fixes (Simple Shell)

Changes made in the simple_shell project:

Ignored comment-only lines (# comment)

Corrected main loop behavior

Ensured builtins correctly affect shell state

Ensured exit status propagation matches /bin/sh

Result:
👉 Shell behavior now matches expectations under real workloads, not just happy paths.

Final Result

All deterministic tests pass

No false negatives

No environment-dependent behavior

Test suite is extensible and auditable

This test suite now acts as:

a correctness validator,

a debugging tool,

and a learning reference.

Audit Verdict

✅ Technically sound
✅ Fair and deterministic
✅ Aligned with Holberton evaluation goals

📘 SIMPLE SHELL — EXAM CHEAT SHEET

Guárdalo como EXAM_NOTES.md o imprímelo.

1. Main Loop (Core Concept)

Your shell is essentially:

while (1)
{
    read input
    parse input
    handle builtins
    fork + exec if needed
    wait
}


If this loop is wrong, everything breaks.

2. read → parse → execute

Key responsibilities:

getline handles input

Trim spaces

Ignore empty lines

Ignore comment-only lines

Tokenize into argv

Decide: builtin or external

3. Builtins vs External Commands
Builtins:

exit

env

setenv

unsetenv

cd

Run inside the shell process.

External commands:

Require fork()

Executed with execve()

Parent must wait()

4. Exit Status Rules

$? always reflects last command

exit with no argument → exit with last status

exit N → exit with N

This is heavily tested.

5. PATH Resolution

Execution order:

Absolute path (/bin/ls)

Relative path (./a.out)

PATH search

If PATH is empty:

Command not found

Exit status = 127

6. Environment Handling

Environment is passed to execve

setenv modifies it

unsetenv removes keys

env prints current environment

Order is not guaranteed.

7. Common Error Codes
Case	Exit Code
Command not found	127
Permission denied	126
exit with no arg	last status
Ctrl-D	exit cleanly
8. Why /bin/sh Matters

/bin/sh is the reference behavior for:

parsing

exit codes

error handling

But not for:

project-specific builtins (setenv, unsetenv)

9. Why This Test Suite Is Strong

Because it:

tests behavior, not formatting

avoids undefined POSIX areas

isolates the environment

mirrors real evaluator expectations
