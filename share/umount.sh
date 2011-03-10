#!/bin/bash
#
# umount wrapper for pam_mount
# schmitt@lmz-bw.de
#
# 18.12.2009
# GPL v3
#

# check if mountpoint is mounted
mounted(){
 if cat /proc/mounts | grep -qw $MNTPT; then
  return 0
 else
  return 1
 fi
}

# parameters given by pammount
USER=$1
MNTPT=$2

# exit if no parameters are set
[[ -z "$USER" || -z "$MNTPT" ]] && exit 1

# source client environment
. /usr/share/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1
. $USERCONFIG || exit 1

# no pam_mount stuff for local users except TEMPLATE_USER
if [ "$TEMPLATE_USER" != "$USER" ]; then
 grep -q ^${USER}: /etc/passwd && exit 0
fi

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# source umount hooks
umount_hooks(){
 if ls $UMOUNTHOOKSDIR/* &> /dev/null; then
  for i in $UMOUNTHOOKSDIR/*; do
   [ -s "$i" ] && . $i
  done
 fi
}

# do this only if mountpoint is userhome
if [ "$HOME" = "$MNTPT" ]; then

 # umount hooks for TEMPLATE_USER
 if [ "$TEMPLATE_USER" = "$USER" ]; then
  umount_hooks
  exit 0
 fi

	# remove user from mandatory groups
	for i in $MANDATORY_GROUPS; do
		grep $i /etc/group | grep -q $USER && deluser ${USER} $i
	done

	# source profile
	. /usr/share/linuxmuster-client/profile || exit 1
	[ -z "$KDEHOME" ] && exit 1
	[ -z "$DESKTOP" ] && exit 1

 # move LINKDIRS back from /tmp
 for i in $LINKDIRS; do
  HOMELINK=$HOME/$i
  TMPLINK=/tmp/${i}-${USER}
  rm -rf $HOMELINK
  mkdir -p $HOMELINK
  for d in cache socket tmp; do
   rm -rf $TMPLINK/${d}-*
  done
  [ -d "$TMPLINK" -a -d "$HOMELINK" ] && rsync -a --delete $TMPLINK/ $HOMELINK/
  chown $USER $HOMELINK -R
  chmod 700 $HOMELINK
 done

 # source umount hooks
 umount_hooks

fi

# umount given share
umount $MNTPT || umount -l $MNTPT
mounted || exit 0
sleep 5
umount $MNTPT || umount -l $MNTPT
mounted || exit 0
kill -9 `lsof -t $MNTPT`
umount $MNTPT || umount -l $MNTPT
RC="$?"

exit $RC

