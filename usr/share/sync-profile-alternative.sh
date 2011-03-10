#
# copy template user profile
#
# 07.03.2011
# Thomas Schmitt
# Frank Schiebel
#

# start logging if enabled
[ x$DEBUGLOG != "x" ] && echo "$0 " > $DEBUGLOG
[ x$DEBUGLOG != "x" ] && date  >> $DEBUGLOG

# if user is template user: do nothing and quit
if [ "$USER" == "$TEMPLATE_USER" ]; then
 [ x$DEBUGLOG != "x" ] && echo "User ist $TEMPLATE_USER - Abbruch"  >> $DEBUGLOG
 return
fi

# sync entire template user profile to userhome
if id "$TEMPLATE_USER" &> /dev/null; then
  # get home of template user
  PROFILE_HOME=$(getent passwd $TEMPLATE_USER | awk -F\: '{ print $6 }')
  if [ -d "$PROFILE_HOME" ]; then
    # copy entire template profile
    OIFS="$IFS"
    IFS=","
    [ x$DEBUGLOG != "x" ] && echo "Kopiere $PROFILE_HOME nach $HOME " >> $DEBUGLOG
    mkdir -p $HOME
    rsync -a -x --delete $PROFILE_HOME/ $HOME/
    chown $USER "$HOME" -R
    # remove items from $PROFILE_IGNORE
    for i in $PROFILE_IGNORE; do
        rm -rf "$HOME/$i"
        [ x$DEBUGLOG != "x" ] && echo "Lösche $HOME/$i " >> $DEBUGLOG
    done
    [ x$DEBUGLOG != "x" ] && ls -la $HOME >> $DEBUGLOG
    IFS="$OIFS"
  fi # home of template user
fi
# profile synced


# check if there is a folder for configs, if not create it
[ -d "$HOME/$SERVER_HOME/$APPS_BASEDIR" ] || mkdir -p "$HOME/$SERVER_HOME/$APPS_BASEDIR"
ln -s  "$HOME/$SERVER_HOME/$APPS_BASEDIR" "$HOME/$APPS_BASEDIR"
chown $USER "$HOME/$APPS_BASEDIR" -R

# link usersettings profile
OIFS="$IFS"
IFS=","
for i in $PROFILE_USER; do
  inlist "$i" "$PROFILE_MANDATORY" && continue
  inlist "$i" "$PROFILE_IGNORE" && continue
  if [ ! -e "$HOME/$SERVER_HOME/$APPS_BASEDIR/$i" ]; then
    [ -e "$HOME/$i" ] && cp -r "$HOME/$i" "$HOME/$SERVER_HOME/$APPS_BASEDIR/$i"
  fi
  [ -e "$HOME/$i" ] && rm -rf "$HOME/$i"
  if [ -e "$HOME/$SERVER_HOME/$APPS_BASEDIR/$i" ]; then
    [ -e "$HOME/$SERVER_HOME/$APPS_BASEDIR/$i" ] && ln -s "$HOME/$SERVER_HOME/$APPS_BASEDIR/$i" "$HOME/$i"
    chown $USER "$HOME/$i" -R
  fi
done # user profile
IFS="$OIFS"


# finally sets permissions for $STUDENTSHOME
if ! check_empty_dir $STUDENTSHOME; then
    chown $ADMINISTRATOR:$TEACHERSGROUP $STUDENTSHOME/*
    chmod 1751 $STUDENTSHOME/*
fi


