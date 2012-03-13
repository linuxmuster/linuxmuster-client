#
# copy template user profile
#
# 14.10.2010
# Thomas Schmitt
#

# not for template user
if [ "$USER" != "$TEMPLATE_USER" ]; then

 # sync mandatory profile
 if id "$TEMPLATE_USER" &> /dev/null; then

  # get home of template user
  PROFILE_HOME=$(getent passwd $TEMPLATE_USER | awk -F\: '{ print $6 }')
  if [ -d "$PROFILE_HOME" ]; then

   OIFS="$IFS"
   IFS=","
   for i in $PROFILE_MANDATORY; do
    inlist "$i" "$PROFILE_IGNORE" && continue
    rm -rf "$HOME/$i"
    mkdir -p "$HOME/$i"
    [ -e "$PROFILE_HOME/$i" ] && rsync -a --delete "$PROFILE_HOME/$i/" "$HOME/$i/"
    chown $USER "$HOME/$i" -R
   done # PROFILE_MANDATORY
   IFS="$OIFS"

  fi # home of template user

 fi # sync mandatory profile

 # link user's dotfiles
 for i in $HOME/$SERVER_HOME/.*; do
  p="$(basename $i)"
  OIFS="$IFS"
  IFS=","
  inlist "$p" "$PROFILE_IGNORE" && continue
  inlist "$p" "$PROFILE_USER" && continue
  inlist "$p" "$PROFILE_MANDATORY" && continue
  IFS="$OIFS"
  rm -rf "$HOME/$p"
  ln -s "$i" "$HOME/$p"
  chown $USER "$HOME/$i"
 done

 # link user's profile
 OIFS="$IFS"
 IFS=","
 for i in $PROFILE_USER; do
  inlist "$i" "$PROFILE_MANDATORY" && continue
  inlist "$i" "$PROFILE_IGNORE" && continue
  [ -e "$HOME/$SERVER_HOME/$i" ] || continue
  rm -rf "$HOME/$i"
  ln -s "$HOME/$SERVER_HOME/$i" "$HOME/$i"
  chown $USER "$HOME/$i"
 done # PROFILE_MANDATORY
 IFS="$OIFS"

fi # not for template user

# create basedir for application settings if necessary
[ -e "$HOME/$APPS_BASEDIR" ] && mkdir -p "$HOME/$APPS_BASEDIR"

# not for template user
if [ "$USER" != "$TEMPLATE_USER" ]; then

 # manage userdirs
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
 fi # manage userdirs

fi # not for template user

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

# be sure to set the owner of the custom app settings directory
[ -e "$HOME/$APPS_BASEDIR" ] && chown -R $USER $HOME/$APPS_BASEDIR

# do the rest not for template user
if [ "$USER" != "$TEMPLATE_USER" ]; then

 # finally sets permissions for $STUDENTSHOME
 if ! check_empty_dir $STUDENTSHOME; then
 	chown $ADMINISTRATOR:$TEACHERSGROUP $STUDENTSHOME/*
 	chmod 1751 $STUDENTSHOME/*
 fi

fi

