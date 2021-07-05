#!/usr/bin/expect

set host [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set script_path [lindex $argv 3]
set timeout [lindex $argv 4]

spawn ssh $username@$host
expect "*yes/no*"
send "yes\n"
expect "password:"
send "$password\n"
expect "*$"
send "./$script_path\n"
expect "*password*"
send "$password\n"
expect "*$"
