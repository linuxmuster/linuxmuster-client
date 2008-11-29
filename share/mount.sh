#!/bin/bash
#
# mount wrapper for pam_mount
# schmitt@lmz-bw.de
#

# args
SERVER=$1
VOLUME=$2
MNTPT=$3
USER=$4
OPTIONS="$5"

# check if params are all set
[ -z "$SERVER" ] && exit 1
[ -z "$VOLUME" ] && exit 1
[ -z "$MNTPT" ] && exit 1
[ -z "$USER" ] && exit 1
[ -z "$OPTIONS" ] && exit 1

# no pam_mount stuff for local users
if grep -q ^${USER}: /etc/passwd; then
#	date >> /tmp/pammount.log
#	echo "$SERVER" >> /tmp/pammount.log
#	echo "$VOLUME" >> /tmp/pammount.log
#	echo "$MNTPT" >> /tmp/pammount.log
#	echo "$USER" >> /tmp/pammount.log
#	echo >> /tmp/pammount.log
	exit 0
fi

# source helperfunctions
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# mount the given share
mount -t cifs //${SERVER}/${VOLUME} $MNTPT -o "$OPTIONS"

# do the rest only if mountpoint is userhome
[ "$HOME" = "$MNTPT" ] || exit 0

# if userhome not mounted do exit
mount | grep -q $HOME || exit 1

# source profile and check if important variables are set
. /usr/share/linuxmuster-client/profile || exit 1
[ -z "$KDEHOME" ] && exit 1
[ -z "$DESKTOP" ] && exit 1
[ -z "$DOTLOCAL" ] && exit 1

# creating user's temporary dirs
for i in $KDEHOME $KDEHOME/Autostart $KDEHOME/share $DESKTOP $DOTLOCAL; do
	[[ -L "$i" || -f "$i" ]] && rm $i
	[ -d "$i" ] || mkdir -p $i
	chown $USER $i
	chmod 700 $i
done

# syncing user's kde settings
if [ -d "$HOME/.kde/share" ]; then
	rsync -a --delete $HOME/.kde/share/ $KDEHOME/share/
elif [ -d "$HOME/.kde.old/share" ]; then
	rsync -a --delete $HOME/.kde.old/share/ $KDEHOME/share/
fi

# syncing user's kde autostart folder
if [ -d "$HOME/.kde/Autostart" ]; then
	rsync -a --delete $HOME/.kde/Autostart/ $KDEHOME/Autostart/
elif [ -d "$HOME/.kde.old/Autostart" ]; then
	rsync -a --delete $HOME/.kde.old/Autostart/ $KDEHOME/Autostart/
fi

# syncing user's desktop
if [ -d "$HOME/Desktop" ]; then
	rsync -a --delete $HOME/Desktop/ $DESKTOP/
elif [ -d "$HOME/.Desktop.old" ]; then
	rsync -a --delete $HOME/.Desktop.old/ $DESKTOP/
fi

# syncing user's .local
if [ -d "$HOME/.local" ]; then
	rsync -a --delete $HOME/.local/ $DOTLOCAL/
elif [ -d "$HOME/.local.old" ]; then
	rsync -a --delete $HOME/.local.old/ $DOTLOCAL/
fi

# move .kde folder in user's home and link it to $KDEHOME
if [ -d "$HOME/.kde" ]; then
	[ -e "$HOME/.kde.old" ] && rm -rf $HOME/.kde.old
	mv $HOME/.kde $HOME/.kde.old
fi
[ -e "$HOME/.kde" ] && rm $HOME/.kde
ln -s $KDEHOME $HOME/.kde
chown $USER $HOME/.kde

# move desktop folder in user's home and link it to $DESKTOP
if [ -d "$HOME/Desktop" ]; then
	[ -e "$HOME/.Desktop.old" ] && rm -rf $HOME/.Desktop.old
	mv $HOME/Desktop $HOME/.Desktop.old
fi
[ -e "$HOME/Desktop" ] && rm $HOME/Desktop
ln -s $DESKTOP $HOME/Desktop
chown $USER $HOME/Desktop

# move .local folder in user's home and link it to $DOTLOCAL
if [ -d "$HOME/.local" ]; then
	[ -e "$HOME/.local.old" ] && rm -rf $HOME/.local.old
	mv $HOME/.local $HOME/.local.old
fi
[ -e "$HOME/.local" ] && rm $HOME/.local
ln -s $DOTLOCAL $HOME/.local
chown $USER $HOME/.local


# add user to mandatory groups
for i in $MANDATORY_GROUPS; do
	if grep -q $i /etc/group; then
		grep $i /etc/group | grep -q $USER || adduser $USER $i
	fi
done

