#!/bin/bash
#
# umount wrapper for pam_mount
# schmitt@lmz-bw.de
#

# parameters given by pammount
USER=$1
MNTPT=$2

# exit if no parameters are set
[[ -z "$USER" || -z "$MNTPT" ]] && exit 1

# no pam_mount stuff for local users
grep -q ^${USER}: /etc/passwd && exit 0

# source helperfunctions
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# do this only if mountpoint is userhome
if [ "$HOME" = "$MNTPT" ]; then

	# source profile
	. /usr/share/linuxmuster-client/profile || exit 1
	[ -z "$KDEHOME" ] && exit 1
	[ -z "$DESKTOP" ] && exit 1

	# creating necessary dirs in user's home
	for i in $HOME/.kde $HOME/.kde/Autostart $HOME/.kde/share $HOME/Desktop; do
		[[ -L "$i" || -f "$i" ]] && rm $i
		[ -d "$i" ] || mkdir -p $i
		chown $USER $i
		chmod 700 $i
	done

	# syncing user's kde settings
	[ -d "$KDEHOME/share" ] && rsync -a --delete $KDEHOME/share/ $HOME/.kde/share/

	# syncing user's kde Autostart
	[ -d "$KDEHOME/Autostart" ] && rsync -a --delete $KDEHOME/Autostart/ $HOME/.kde/Autostart/

	# syncing user's desktop
	[ -d "$DESKTOP" ] && rsync -a --delete $DESKTOP/ $HOME/Desktop/

	# removing kdehome and desktop dirs
	rm -rf $KDEHOME
	rm -rf $DESKTOP

fi

# umount given share
umount $MNTPT
status=$?

# if unmounting fails kill processes which prevent $MNTPT from unmounting
# and do a second try
if [ "$status" -ne 0 ]; then

	sleep 5
	for i in `lsof | grep $MNTPT | awk '{ print $2 }'`; do
		kill $i
	done
	umount $MNTPT
	status=$?

fi

# exit with umount status
exit $status
