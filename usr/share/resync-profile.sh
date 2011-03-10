#
# sync user profile back to server home
#
# 14.10.2010
# Thomas Schmitt
#

# sync user profile dirs back to server
OIFS="$IFS"
IFS=","

for i in $PROFILE_USER; do

 [ -L "$HOME/$i" ] && continue
 inlist "$i" "$PROFILE_IGNORE" && continue
 inlist "$i" "$PROFILE_MANDATORY" && continue

 if [ -e "$HOME/$i" ]; then
  rm -rf "$HOME/$SERVER_HOME/$i"
  mv "$HOME/$i" "$HOME/$SERVER_HOME"
  chown $USER "$HOME/$SERVER_HOME/$i" -R
 fi

done

for i in $HOME/.*; do

 [ -L "$i" ] && continue
 p="$(basename $i)"
 inlist "$p" "$PROFILE_MANDATORY" && continue
 inlist "$p" "$PROFILE_USER" && continue
 inlist "$p" "$PROFILE_IGNORE" && continue

 rm -rf "$HOME/$SERVER_HOME/$p"
 mv "$i" "$HOME/$SERVER_HOME"
 chown $USER "$HOME/$SERVER_HOME/$i" -R

done

IFS="$OIFS"

