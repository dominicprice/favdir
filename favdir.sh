#!/bin/bash
#
# favdir.sh --- Shortcut location manager for bash.
# run `source /path/to/favdir.sh` and then type favdir -h to view the help page
#
# Copyright 2021 Dominic Price
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
# files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
# modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# If the FAVDIR_DB is not set, default it to ~/.favdirs
if [[ -z "$FAVDIR_DB" ]]; then
	FAVDIR_DB="$HOME/.favdirs"
fi

# Create $FAVDIR_DB if it doesn't already exist and then import all names from it
touch "$FAVDIR_DB"
source "$FAVDIR_DB"

function __favdir_help {
	echo "favdir: Manage and recall shortcut directory names by creating environment variables for locations."
	echo "Usage: favdir [-h|--help] [-l|--list [NAME] ] [-r|--remove NAME] [ -c|--create [NAME] ] [ -g | --go NAME ]"
	echo "       (1) favdir"
	echo "       (2) favdir NAME"
	echo "  -h   Print this help message and exit"
	echo "  -l   Print a list of all currently set favdirs. If NAME is given then results are filtered"
	echo "       by this search term"
	echo "  -r   Remove an entry"
	echo "  -c   Create an entry for the current pwd. If NAME is not given, name of current directory"
	echo "       converted to uppercase is used."
	echo "  -g   Search all favdirs for a shortcut matching the pattern NAME and cd into it"
	echo "  (1)  Equivalent to favdir --list"
	echo "  (2)  Equivalent to favdir --create NAME"
}

function __favdir_list {
	local colwidth=$(awk -F= -v x=0 'length($1)>x {x=length($1)}; END{print x}' "$FAVDIR_DB")
	awk -F= -v colwidth="$colwidth" -v search=".*$1.*" 'BEGIN {IGNORECASE=1}; $1 ~ search {printf "%-" colwidth "s  %s\n", $1, $2}' "$FAVDIR_DB"
}

function __favdir_create {
	# If no name given then use current directory name
	if [[ -z "$1" ]]; then
		local NAME="${PWD##*/}"
		local NAME="${NAME^^}"
	else
		local NAME="$1"
	fi
	# Ensure name is a valid bash variable identifier
	if ! [[ "$NAME" =~ ^[_a-zA-Z][a-zA-Z0-9_]*$ ]]; then
		echo "Name '$NAME' is not a legal bash variable identifier"
		return 1
	fi
	# Append to $FAVDIR_DB and re-source to load name
	echo "$NAME=$PWD" >> "$FAVDIR_DB"
	echo "Created alias $NAME for $PWD"
	source "$FAVDIR_DB"
}

function __favdir_remove {
	if [[ -z "$1" ]]; then
		echo "Required parameter NAME missing; try --help for more information"
		return 1
	fi
	# Get current number of entries and compare to file after we have filtered out
	# $1 to see if we actually found the entry or not
	local nentries=$(wc -l "$FAVDIR_DB")
 	awk -F= -i inplace -v search="$1" '{if ($1 != search) print $0}' "$FAVDIR_DB"
	if [[ "$(wc -l $FAVDIR_DB)" == "$nentries" ]]; then
		echo "Could not find entry $1"
		return 1
	else
		unset "$1"
		echo "Removed alias $1"
	fi
}

function __favdir_go {
	if [[ -z "$1" ]]; then
		echo "Required parameter NAME missing; try --help for more information"
		return 1
	fi
	local ENTRIES=$(awk -F= -v search=".*$1.*" 'BEGIN {IGNORECASE=1}; $1 ~ search {print $1}' "$FAVDIR_DB")
	local NENTRIES=$(echo "$ENTRIES" | wc -l)
	if [[ -z "$ENTRIES" ]]; then
		echo "Could not find any entries matching $1"
		return 1
	elif [[ "$NENTRIES" == "1" ]]; then
		cd "${!ENTRIES}"
	else
		echo "Found multiple entries matching $1:"
		echo "$ENTRIES"
		return 1
	fi
}

function favdir {
	case $1	in
		"-h" | "--help")
			__favdir_help
			;;
		"-l" | "--list")
			__favdir_list "$2"
			;;
		"-r" | "--remove")
			__favdir_remove "$2"
			;;
		"-c" | "--create")
			__favdir_create "$2"
			;;
		"-g" | "--go")
			__favdir_go "$2"
			;;
		*)
			if [[ "$#" == "0" ]]; then
				__favdir_list
			else
				__favdir_create "$1"
			fi
			;;
	esac
}
