#!/bin/bash
#
# mount wrapper for pam_mount
# schmitt@lmz-bw.de
#
# 08.11.2009
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

# source various settings and functions
. /usr/share/linuxmuster-client/profile || exit 1
. /etc/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# only for template user
[ "$TEMPLATE_USER" = "$USER" -a "$HOME" = "$MNTPT" ] && . /usr/share/linuxmuster-client/copy-template.sh

# no pammount for local users
grep -q ^${USER}: /etc/passwd && exit 0

# check if important variables are set
[ -z "$KDEHOME" ] && exit 1
[ -z "$DESKTOP" ] && exit 1
[ -z "$USERDIRS" ] && exit 1

# mount the given share
mount -t cifs //${SERVER}/${VOLUME} $MNTPT -o "$OPTIONS"

# do the rest only if mountpoint is userhome
[ "$HOME" = "$MNTPT" ] || exit 0

# if userhome not mounted do exit
cat /proc/mounts | grep -qw $HOME || exit 1

# move user's dirs temporarily to /tmp
for i in $USERDIRS; do
 [ -e "/tmp/${i}-${USER}" -a ! -d "/tmp/${i}-${USER}" ] && rm -rf /tmp/${i}-${USER}
 [ -d "/tmp/${i}-${USER}" ] || mkdir -p /tmp/${i}-${USER}
 [ -d "$HOME/$i" ] && rsync -a --delete $HOME/$i/ /tmp/${i}-${USER}/
 rm -rf $HOME/$i
 ln -s /tmp/${i}-${USER} $HOME/$i
 chown $USER /tmp/${i}-${USER} -R
 chmod 700 /tmp/${i}-${USER}
done

# copy template user profile
. /usr/share/linuxmuster-client/copy-template.sh

