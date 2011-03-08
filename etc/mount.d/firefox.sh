#
# Mount hook for firefox profile
#
# 08.03.2011
# Thomas Schmitt
# Frank Schiebel
#

# process firefox profile if requested
if [ "$FIREFOX" = "yes" ]; then

 # create default firefox profile dir if necessary
 [ -d $HOME/.mozilla/firefox ] || mkdir -p $HOME/.mozilla/firefox

 # create profiles.ini with path to custom profile directory
 echo -e "[General]\nStartWithLastProfile=1\n\n[Profile0]\nName=firefox\nIsRelative=1\nPath=../../$APPS_BASEDIR/$FIREFOX_PROFILE\nDefault=1\n\n" > $HOME/.mozilla/firefox/profiles.ini
 chown -R $USER $HOME/.mozilla

 # create custom firefox profile directory
 if [ ! -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ]; then

  # skip this if user is template user
  if [ "$USER" != "$TEMPLATE_USER" ]; then
   [ -e "$PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE" ] && cp -a $PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE $HOME/$APPS_BASEDIR
  fi

  # create it if it was not copied
  [ -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ] || mkdir $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE

 fi

fi
