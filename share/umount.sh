#!/bin/bash
#
# umount wrapper for pam_mount
# schmitt@lmz-bw.de
#
# 11.07.2009
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

# no pam_mount stuff for local users
grep -q ^${USER}: /etc/passwd && exit 0

# source helperfunctions
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1

# fetch user's homedir
get_userhome
[[ -z "$HOME" || "$HOME" = "/dev/null" ]] && exit 1

# do this only if mountpoint is userhome
if [ "$HOME" = "$MNTPT" ]; then

	# remove user from mandatory groups
	for i in $MANDATORY_GROUPS; do
		grep $i /etc/group | grep -q $USER && deluser ${USER} $i
	done

	# source profile
	. /usr/share/linuxmuster-client/profile || exit 1
	[ -z "$KDEHOME" ] && exit 1
	[ -z "$DESKTOP" ] && exit 1
	[ -z "$USERDIRS" ] && exit 1

 # move user's dir back from /tmp
 for i in $USERDIRS; do
  rm -rf $HOME/$i
  mkdir -p $HOME/$i
  for d in cache socket tmp; do
   rm -rf /tmp/${i}-${USER}/${d}-*
  done
  [ -d "/tmp/${i}-${USER}" -a -d "$HOME/$i" ] && rsync -a --delete /tmp/${i}-${USER}/ $HOME/$i/
  chmod 700 $HOME/$i
 done

fi

# umount given share
umount $MNTPT
mounted || exit 0
sleep 5
umount $MNTPT
mounted || exit 0
kill -9 `lsof -t $MNTPT`
umount $MNTPT || umount -l $MNTPT
RC="$?"

exit $RC

