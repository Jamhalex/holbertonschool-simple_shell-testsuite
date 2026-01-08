name=exit uses last command status
input=/bin/ls /nope\nexit\n
env=default
expect_status=2

