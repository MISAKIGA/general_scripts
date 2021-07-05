#! /bin/sh

set host [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]
set script_path [lindex $argv 3]

ssh -tt  $host "source $script_path"

