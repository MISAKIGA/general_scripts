#!/usr/bin/expect

set timeout 3
set host [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set dir [lindex $argv 3]

spawn ssh $username@$host
expect "password:"
send "$password\n"
expect "*$"
send "mkdir -p $dir\n"
expect "*$"
