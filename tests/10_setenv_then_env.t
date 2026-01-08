name=setenv sets variable (FOOBAR)
notes=Assert behavior: after setenv, FOOBAR must be readable via printenv (no pipes).
input=setenv FOOBAR hello\nprintenv FOOBAR\nexit\n
env=default
expect_status=0
expect_stdout=hello\n
expect_stderr=
sort_stdout=0

