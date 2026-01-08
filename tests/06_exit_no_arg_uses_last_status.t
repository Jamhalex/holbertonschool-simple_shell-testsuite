name=exit uses last command status
input=nosuchcommand\nexit\n
env=default
expect_status=127
expect_stdout=
expect_stderr=
