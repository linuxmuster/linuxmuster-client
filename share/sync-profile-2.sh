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
 exit 0
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

# check if there is a folder for configs, if not create it
[ -d "$HOME/$SERVER_HOME/$APPS_BASEDIR" ] || mkdir -p "$HOME/$SERVER_HOME/$APPS_BASEDIR"

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


# process firefox profile if requested
if [ "$FIREFOX" = "yes" ]; then

 # create default firefox profile dir if necessary
 [ -d $HOME/.mozilla/firefox ] || mkdir -p $HOME/.mozilla/firefox

 # create profiles.ini with path to custom profile directory
 echo -e "[General]\nStartWithLastProfile=1\n\n[Profile0]\nName=firefox\nIsRelative=1\nPath=../../$APPS_BASEDIR/$FIREFOX_PROFILE\nDefault=1\n\n" > $HOME/.mozilla/firefox/profiles.ini
 chown -R $USER $HOME/.mozilla

 # create custom firefox profile directory
 if [ ! -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ]; then

[ -e "$PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE" ] && cp -a $PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE $HOME/$APPS_BASEDIR

# create it if it was not copied
[ -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ] || mkdir $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE

 fi

fi

# finally sets permissions for $STUDENTSHOME
if ! check_empty_dir $STUDENTSHOME; then
    chown $ADMINISTRATOR:$TEACHERSGROUP $STUDENTSHOME/*
    chmod 1751 $STUDENTSHOME/*
fi


