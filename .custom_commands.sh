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

# set the week strings as enviroment variable, so that it can be referenced in code
# for example, for labelling folders of research pictures
# the format is WKSTR_[day of week symobl] = `[month][day]_[yr]` 
# the week "starts" at the next day--so if it is Tuesday 
function wkstr() {
	eval $(python3 ~/bin/wkstr.py "$@")
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

function srcrc() {
	source ~/.bash_profile
}

#---SHORTCUTS FOR C++ DEVELOPMENT---#

function makec(){
	mkdir "$1"
	cd "$1"
	touch "CMakeLists.txt"
	cmaketext="cmake_minimum_required(VERSION 3.6)
project($1)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(code_dir \"\${PROJECT_SOURCE_DIR}/code\")
include_directories(\${code_dir})
file(GLOB_RECURSE srcs \${code_dir}/*.cpp)
file(GLOB_RECURSE header_files \${code_dir}/*.hpp)
add_executable($1 \${srcs} \${header_files})
" 
	printf "$cmaketext" >> CMakeLists.txt

	mkdir "code"
	touch "code/main.cpp"

	ctext="#include <iostream>

int main() {
	std::cout << \"hello!\" << std::endl;
}
"
	printf "$ctext" >> code/main.cpp
	mkdir build
	cd build
	cmake ..
	make
	cd ../..
	echo ""
	echo "Created c++ project for $1"
}

function chpp(){
	touch "$1.cpp"
	touch "$1.hpp"
}

#---UTILITY FUNCTIONS---#

function notify() {
	osascript -e "display notification \"$2\" with title \"$1\""
	nohup afplay /System/Library/Sounds/Ping.aiff >/dev/null 2>$1 &
}

function makegif() {
	convert -delay $1 -loop 0 -dispose previous *.png gif.gif
}


# quickly profile a python function
# not intended for extensive/long experimentation since it will delete the 
# profile data after running
# Use: prof <python file>
function prof() {
	python3 -m cProfile -o ~/tmp/temp_profile.prof $1
	snakeviz ~/tmp/temp_profile.prof
	rm ~/tmp/temp_profile.prof
}

#---SSH MANAGMENT FUNCTIONS---#

# ssh alias for csail servers
function sshcsail() {
	kinit -R -f zoem@CSAIL.MIT.EDU 2> /dev/null || kinit --renewable -f zoem@CSAIL.MIT.EDU
	ssh $1.csail.mit.edu -l zoem
}


