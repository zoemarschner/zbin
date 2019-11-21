#!/bin/bash

#---CUSTOM PTYTHON COMMANDS---#

# test function!
function hi() {
  python3 ~/bin/hi.py "$@"
}

#cd short cuts, to get to folders I am working on a lot 
function cdsc() {
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		python3 ~/bin/cdsc.py "$@"
	else
		command=$(python3 ~/bin/cdsc.py "$@")
		eval $command
	fi
}

#---SIMPLE SHORTCUTS---#

# makes new directory and creates virtual enviorment 
function mkenv() {
	mkdir $1
	cd $1
	virtualenv venv
	source venv/bin/activate
}

#start virtual enviorment in current directory
function srcenv() {
	source venv/bin/activate
}


