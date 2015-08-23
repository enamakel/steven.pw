#!/bin/bash
# Well, I have wasted good deal of time here.

TTY1_CONF=/etc/init/tty1.conf
GIT_REPO="https://github.com/enamakel/nSnake.git"

CWD=`mktemp -d`
ERROR_FILE=$CWD/error.log
SCRIPT_ROOT=`pwd`
STDOUT_FILE=$CWD/output.log

COUNTER=0

# Prepares the configuration file that we will use for our TTY
prepare_conf() {
	echo "start on stopped rc RUNLEVEL=[2345] and ( "
	echo "        not-container or"
	echo "         container CONTAINER=lxc or"
	echo "         container CONTAINER=lxc-libvirt)"
	echo ""
	echo "stop on runlevel [!2345]"
	echo ""
	echo "respawn"
	echo ""
	printf 'exec %s -e %s </dev/tty1 >/dev/tty1' "$1" "$2"
}

# Runs the program while at the same time redirecting stdout and stderr. We want
# to keep the terminal screen clean, so that we can print some nursery rhymes.
run() {
	if !($@ 1>$STDOUT_FILE 2>$ERROR_FILE) then
		printf "\
			\nAn error has occurred in this step.\
			\nView the files below for more info\
			\nStdout dump file: %s\
			\nError  dump file: %s\n\n" $STDOUT_FILE $ERROR_FILE
		echo "Command: '$@'"
		cat $ERROR_FILE
		exit
	fi
	:
}

# Probably the most useless function I have ever written.
#
# This function is responsible for print out the given statement with an index
# of it, as well as print a line from the English Nursery rhyme wherever
# necessary
nrhyme() {
	RHYMES=("Buckle my shoe" "Shut the door" "Pick up the sticks" \
		"Lay them straight" "A big fat hen")
	COUNTER=$((COUNTER + 1))
	echo "$COUNTER". $@

	INDEX=

	case "$COUNTER" in
		2)  INDEX="0" ;;
		4)  INDEX="1" ;;
		6)  INDEX="2" ;;
		8)  INDEX="3" ;;
		10) INDEX="4" ;;
	esac

	[ -z "$INDEX" ] || (printf "%s\n\n" "${RHYMES[$INDEX]}" && sleep 1)
}

# This function checks if the user is root or not. If not, then the script tries
# to run itself with root privileges.
checkifRoot() {
	if [ "$(id -u)" != "0" ]; then
		echo "This script must be run as root"
		exit
	fi
}

# First check if you are root
checkifRoot

nrhyme "Installing dependencies"
run apt-get install libncurses5-dev

nrhyme "Creating temporary working directory"
cd $CWD

nrhyme "Downloading nSnake from the repo"
run git clone --depth 1 $GIT_REPO

nrhyme "Compiling nSnake"
cd nSnake
run make

nrhyme "Installing nSnake"
run make install

nrhyme "Finding current display manager (DM)"
DISPLAY_MANAGER=$(cat /etc/X11/default-display-manager)
DISPLAY_MANAGER_CONF="/etc/init/`basename $DISPLAY_MANAGER`.conf"

nrhyme "Disabling DM from starting during boot"
if [ -f $DISPLAY_MANAGER_CONF ]; then
	run mv $DISPLAY_MANAGER_CONF $DISPLAY_MANAGER_CONF".disable"
fi

nrhyme "Making a backup of TTY1's conf file"
if [ -f $TTY1_CONF ]; then
	run mv $TTY1_CONF $TTY1_CONF".backup"
fi

nrhyme "Writing a custom conf for TTY1"
prepare_conf "/usr/bin/nsnake" $DISPLAY_MANAGER > $TTY1_CONF

nrhyme "Cleaning up"
rm -rf $CWD

echo Contribute @ $GIT_REPO

exit