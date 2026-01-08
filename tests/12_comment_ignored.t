name=comment-only line should do nothing
notes=Even if comments aren't implemented, shell must not crash.
input=# just a comment\nexit\n
env=default
expect_status=0
expect_stdout=
expect_stderr=
