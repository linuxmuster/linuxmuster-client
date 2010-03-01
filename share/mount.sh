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
. /usr/share/linuxmuster-client/profile || exit 1
. /usr/share/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1
. $USERCONFIG || exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# not for TEMPLATE_USER
if [ "$TEMPLATE_USER" != "$USER" ]; then
 # no pammount for local users exept TEMPLATE_USER
 grep -q ^${USER}: /etc/passwd && exit 0
 # check if important variables are set
 [ -z "$KDEHOME" ] && exit 1
 [ -z "$DESKTOP" ] && exit 1
 # mount the given share
 mount -t cifs //${SERVER}/${VOLUME} $MNTPT -o "$OPTIONS"
fi

# do the rest only if mountpoint is userhome
[ "$HOME" = "$MNTPT" ] || exit 0

# only for ldap users
if [ "$TEMPLATE_USER" != "$USER" ]; then
 # if userhome not mounted do exit
 cat /proc/mounts | grep -qw $HOME || exit 1
 # move LINKDIRS temporarily to /tmp and link them to user's home
 for i in $LINKDIRS; do
  HOMELINK=$HOME/$i
  TMPLINK=/tmp/${i}-${USER}
  [ -e "$TMPLINK" -a ! -d "$TMPLINK" ] && rm -rf $TMPLINK
  [ -d "$TMPLINK" ] || mkdir -p $TMPLINK
  [ -d "$HOMELINK" ] && rsync -a --delete $HOMELINK/ $TMPLINK/
  rm -rf $HOMELINK
  ln -s $TMPLINK $HOMELINK
 done
fi

 # copy template user profile only if TEMPLATE_USER is set
[ -n "$TEMPLATE_USER" ] && . /usr/share/linuxmuster-client/copy-template.sh

# only for ldap users
if [ "$TEMPLATE_USER" != "$USER" ]; then
 # repair permissions on LINKDIRS
 for i in $LINKDIRS; do
  HOMELINK=$HOME/$i
  TMPLINK=/tmp/${i}-${USER}
  chown $USER $TMPLINK -R
  chown $USER $HOMELINK
  chmod 700 $TMPLINK
 done
fi

# source mount hooks
ls $MOUNTHOOKSDIR/* &> /dev/null || exit 0
for i in $MOUNTHOOKSDIR/*; do
 [ -s "$i" ] && . $i
done

