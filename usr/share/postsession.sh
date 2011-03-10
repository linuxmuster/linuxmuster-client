#!/bin/bash
#
# postsession script
# schmitt@lmz-bw.de
#
# 21.10.2010
# GPL v3
#

# check if mounted
mounted(){
 local MNT="$1"
 if cat /proc/mounts | grep -qw "$MNT"; then
  return 0
 else
  return 1
 fi
}

# parameters given by PostSession
USER=$1
HOME=$2

# exit if no parameters are set
[ -z "$USER" -o -z "$HOME" ] && exit 1

echo "PostSession for $USER starts."

# filter workstations 
"$HOME" = "/dev/null" && exit 1

# source client environment
. /usr/share/linuxmuster-client/config || exit 1
. /usr/share/linuxmuster-client/helperfunctions.sh || exit 1
. $USERCONFIG || exit 1

# no pam_mount stuff for local users except TEMPLATE_USER
if [ "$TEMPLATE_USER" != "$USER" ]; then
 grep -q ^${USER}: /etc/passwd && exit 0
fi

# source umount hooks
umount_hooks(){
 if ls $UMOUNTHOOKSDIR/* &> /dev/null; then
  for i in $UMOUNTHOOKSDIR/*; do
   [ -s "$i" ] && . $i
  done
 fi
}

# umount hooks for TEMPLATE_USER
if [ "$TEMPLATE_USER" = "$USER" ]; then
 umount_hooks
 exit 0
fi

# sync user profile back
if [ $SYNC_MODE == "alternative" ]; then
. /usr/share/linuxmuster-client/resync-profile-alternative.sh
else
. /usr/share/linuxmuster-client/resync-profile.sh
fi
# source umount hooks
umount_hooks

# unmount user shares
for i in `grep ^\<volume /etc/security/pam_mount.conf.xml | awk -F\= '{ print $5 }' | awk -F\" '{ print $2 }' | sed -e "s|\~|$HOME|g"`; do
 echo "Hänge $i aus ..."
 if mounted "$i"; then
  if ! umount "$i"; then
   umount "$i" || umount -l "$i"
  fi
 fi
done

# delete user home
if ! mounted "$HOME/$SERVER_HOME"; then
 echo "Lösche Userhome $HOME ..."
 rm -rf "$HOME"
fi

