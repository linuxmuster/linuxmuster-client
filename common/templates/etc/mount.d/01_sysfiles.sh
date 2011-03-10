# Manage sysdirs
#
# 07.03.2011
# Thomas Schmitt
# Frank Schiebel
#

# if user is template user: do nothing and quit
if [ "$USER" == "$TEMPLATE_USER" ]; then
 [ x$DEBUGLOG != "x" ] && echo "User ist $TEMPLATE_USER - Abbruch"  >> $DEBUGLOG
 return
fi

# manage system dirs for user
if [ -n "$MYFILES" ]; then
  mkdir -p "$HOME/$SERVER_HOME/$MYFILES"
  chown $USER "$HOME/$SERVER_HOME/$MYFILES"
  OIFS="$IFS"
  IFS=","
  for i in $MYFILES_SUPP $MYFILES_LINK; do
    [ -e "$HOME/$i" ] && rm -rf "$HOME/$i"
  done
  rm -rf "$HOME/$MYFILES_LINK"
  rm -rf "$HOME/Desktop/$MYFILES"
  ln -s "$HOME/$SERVER_HOME/$MYFILES" "$HOME/$MYFILES"
  chown $USER "$HOME/$MYFILES"
  ln -s "$HOME/$SERVER_HOME/$MYFILES" "$HOME/$MYFILES_LINK"
  chown $USER "$HOME/$MYFILES_LINK"
  ln -s "$HOME/$SERVER_HOME/$MYFILES" "$HOME/Desktop/$MYFILES"
  chown $USER "$HOME/Desktop/$MYFILES"
  for i in $MYFILES_SUPP; do
    mkdir -p "$HOME/$SERVER_HOME/$MYFILES/$i"
    chown $USER "$HOME/$SERVER_HOME/$MYFILES/$i"
    rm -rf "$HOME/$i"
    ln -s "$HOME/$SERVER_HOME/$MYFILES/$i" "$HOME/$i"
    chown $USER "$HOME/$i"
  done
  IFS="$OIFS"
  [ x$DEBUGLOG != "x" ] && "Systemlinks angelegt:" >> $DEBUGLOG
  [ x$DEBUGLOG != "x" ] && ls -la $HOME >> $DEBUGLOG
  [ x$DEBUGLOG != "x" ] && ls -la $HOME/$MYFILES >> $DEBUGLOG
fi
# manage userdirs

# Add nautilus bookmark for MYFILES
bookmark="file:///$HOME/$MYFILES"
sed -i "1i$bookmark" $HOME/.gtk-bookmarks
