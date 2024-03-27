#!/bin/bash

#---ALIASES---#

alias bpy='blender --background --python'

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

# quickly profile a python function
# not intended for extensive/long experimentation since it will delete the 
# profile data after running
# Use: prof <python file>
function prof() {
	python3 -m cProfile -o ~/tmp/temp_profile.prof $1
	snakeviz ~/tmp/temp_profile.prof
	rm ~/tmp/temp_profile.prof
}

# shortcut to start a python interactive shell and import numpy 
function numpy() {
	python3 -i -c"import numpy as np"
}


#---IMAGE/VIDEO UTILITY FUNCTION---#

# makes a gif out of a sequence of numbered pngs; the first argument gives the delay, a delay value
# of N means N/100 seconds between frames aka FPS = 100/N
function makegif() {
	convert -delay $1 -loop 0 -dispose previous *.png gif.gif
}


# crop an image saved from polyscope, with cropping parameters tailored to cut out white space 
# generated from the typical un-modified polyscope camera. input image should be 3024x1832
function pscrop() {
	convert $1 -crop 1524x1382+750+450 cropped_$1

}

# crops all files in the folder that do not begin with "crop" using pscrop  
function pscropall() {
	for file in *.png; do 
    if [[ $file != cropped* ]]; then 
      pscrop $file
    fi 
	done
}


# makes a .mp4 video out of a sequence of pngs in the current folder with a solid colored background
# the first argument is the color or the background, the second is the framerate (default 20)
# the color can either be a hex code (NO #) OR one of these shortcuts:
# 	- white: ffffff
#		- obs: 	 151515 (matches background of my obsidian)
function ffcol() {
	files=(*.png)
	size=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 ${files[0]})

	color="$1"

	if [[ $1 == white ]]; then
		color=ffffff 
	elif [[ $1 == obs ]]; then
		color=151515 
	fi

	echo $color

	ffmpeg -f lavfi -i color=c=#${color}:s=${size} -framerate ${2:-20} -pattern_type glob -i '*.png' -filter_complex "overlay=shortest=1" -pix_fmt yuv420p out2.mp4
}	

# makes a .mov video out of a sequence of pngs in the current folder with a transparent background
# the first arugment gives the framerate (default 20)
function fftrans() {
	ffmpeg -framerate ${1:-20} -pattern_type glob -i '*.png' -vcodec prores_ks -profile: 4444 -pix_fmt yuva444p10le out.mov
}


#---SSH MANAGMENT FUNCTIONS---#

# ssh alias for csail servers
function sshcsail() {
	kinit -R -f zoem@CSAIL.MIT.EDU 2> /dev/null || kinit --renewable -f zoem@CSAIL.MIT.EDU
	ssh $1.csail.mit.edu -l zoem
}

function sshscs() {
	kinit -R -f zmarschn@CS.CMU.EDU 2> /dev/null || kinit --renewable -f zmarschn@CS.CMU.EDU
	ssh zmarschn@linux.gp.cs.cmu.edu
}


