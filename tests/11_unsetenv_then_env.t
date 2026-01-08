name=unsetenv removes variable (FOOBAR)
notes=Assert behavior: after unsetenv, printenv should not output FOOBAR. We end with echo DONE and expect only DONE.
input=setenv FOOBAR hello\nunsetenv FOOBAR\nprintenv FOOBAR\necho DONE\nexit 0\n
env=default
expect_status=0
expect_stdout=DONE\n
expect_stderr=
sort_stdout=0
