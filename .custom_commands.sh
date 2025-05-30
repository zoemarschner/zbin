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
# the week "starts" at the next day
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

# crop an image or list of images by specified number of pixels in each dimension
function zcrop() {

	USAGE=$(cat <<-END
		Usage: zcrop [-f] [-h] [-o] [-l lpix] [-r rpix] [-u upix] [-d dpix] [file glob] -- crop an image or list of images

		Options:
		  -l,-r,-u,-d set how much to crop in (l)eft, (r)ight, (u)p, and (d)own directions
		  -f overrides orignal image (otherwise 'cropped_' is added to filename)
		  -h shows this message
		  -o forces all images to be output as RGBA (as opposed to pallete + alpha) (standardizes images but may lead to larger files)
	END
	)

	opt_f=false
	opt_o=false

	opt_l=0
	opt_r=0
	opt_u=0
	opt_d=0

	local OPTIND opt f h l r u d o

	while getopts fhol:r:u:d: opt; do
		case ${opt} in
			f) opt_f=true ;;
			h) opt_h=
				echo "$USAGE"
				return 
				;;
			l) opt_l=${OPTARG} ;;
			r) opt_r=${OPTARG} ;;
			u) opt_u=${OPTARG} ;;
			d) opt_d=${OPTARG} ;;
			o) opt_o=true ;;
			*) 
				echo "$USAGE"
				return 
				;;
		esac
	done

	shift "$(( OPTIND - 1 ))"
	"$opt_f" && filestr="" || filestr="cropped_"

	img_prefix=""
	if $opt_o; then
		img_prefix="PNG32:"
	fi


	# loop through files that don't begin with cropped
	for file in "$@"; do
		if [[ $file != cropped* ]]; then 
			width=$(identify -format '%w' $file)
			height=$(identify -format '%h' $file)
			
			res_width=$(($width - $opt_l - $opt_r))
			res_height=$(($height - $opt_u - $opt_d))

			magick ${file} -crop ${res_width}x${res_height}+${opt_l}+${opt_u} ${img_prefix}${filestr}${file}
		fi
	done
}

# shortcuts for zcrop targeted at results screenshotted from polyscope with frequently used meshes 
function zcropshape() {
	usage="Usage: zcropshape [shape] [zcrop arguments] -- currently supported shapes: bunny, sphere, spher_tight, plane, disk, disk_sdf, ajax"

	case $1 in 
		bunny) zcrop -l 800 -r 850 -u 300 -d 150 ${@:2};;#-l 550 -u 325 -r 620 -d 175 ${@:2};;
		sphere) zcrop -l 350 -r 350 ${@:2};;
		sphere_tight) zcrop -l 700 -r 700  -u 100 -d 100  ${@:2};;
		plane) zcrop -l 650 -r 650 -u 300 -d 300 ${@:2};;
		disk) zcrop -l 610 -r 610 -d 100 -u 100 ${@:2};;
		disk_sdf) zcrop -l 600 -r 600 ${@:2};;
		ajax) zcrop -l 1010 -r 1030 -u 200 -d 120 ${@:2};;
		*) 
			echo "$usage"
			return  
			;;
	esac
}


# crop an image saved from polyscope, with SET cropping parameters tailored to cut out white space 
# generated from the typical un-modified polyscope camera. input image should be 3024x1832
function pscrop() {
	usage="Usage: pscrop [-f] [-h] [-x nx] [-y ny] [filename] -- crop an image to cut out whitespace in polyscope screenshots, -f overrides orignal image, nx and ny offset the crop window"
	opt_f=false
	opt_x=0
	opt_y=0

	local OPTIND opt f h x y

	while getopts fhx:y: opt; do
		case ${opt} in
			f) opt_f=true ;;
			h) opt_h=
				echo "$usage"
				return 
				;;
			x) opt_x=${OPTARG} ;;
			y) opt_y=${OPTARG} ;;
			*) 
				echo "$usage"
				return 
				;;
		esac
	done

	shift "$(( OPTIND - 1 ))"

	x_mv=$(($opt_x + 750))
	y_mv=$(($opt_y + 450))

	"$opt_f"  && filestr="" || filestr="cropped_"

	magick $1 -crop 1524x1382+${x_mv}+${y_mv} ${filestr}$1

}

# crops all files in the folder that do not begin with "crop" using pscrop  
function pscropall() {
	for file in *.png; do 
		if [[ $file != cropped* ]]; then 
			pscrop "$@" $file 
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

	ffmpeg -f lavfi -i color=c=#${color}:s=${size} -framerate ${2:-20} -pattern_type glob -i '*.png' -filter_complex "overlay=shortest=1" -pix_fmt yuv420p out.mp4
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


