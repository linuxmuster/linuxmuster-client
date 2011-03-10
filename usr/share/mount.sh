#!/bin/bash
#
# mount wrapper for pam_mount
# schmitt@lmz-bw.de
#
# 18.12.2009
# GPL v3
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
. /usr/share/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1
. $USERCONFIG || exit 1

# exit if SERVER_HOME is not set
[ -z "$SERVER_HOME" ] && exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# not for TEMPLATE_USER
if [ "$TEMPLATE_USER" != "$USER" ]; then
 # no pammount for local users exept TEMPLATE_USER
 grep -q ^${USER}: /etc/passwd && exit 0
 # mount the given share
 mount -t cifs //${SERVER}/${VOLUME} $MNTPT -o "$OPTIONS" || exit 1
fi

# do the rest only if mountpoint is userhome
[ "$HOME/$SERVER_HOME" = "$MNTPT" ] || exit 0

# sync user profile
if [ $SYNC_MODE == "alternative" ]; then
. /usr/share/linuxmuster-client/sync-profile-alternative.sh
else
. /usr/share/linuxmuster-client/sync-profile.sh
fi

# source mount hooks
ls $MOUNTHOOKSDIR/* &> /dev/null || exit 0
for i in $MOUNTHOOKSDIR/*; do
 [ -s "$i" ] && . $i
done

