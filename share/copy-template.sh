#
# copy template user profile
#
# 08.11.2009
# Jörg Richter/Thomas Schmitt
#

# quit if TEMPLATE_USER is not set
[ -z "$TEMPLATE_USER" ] && exit 0

# get home of template user
PROFILE_HOME=$(getent passwd $TEMPLATE_USER | awk -F\: '{ print $6 }')

# create basedir for application settings if necessary
[ -d $HOME/$APPS_BASEDIR ] || mkdir -p $HOME/$APPS_BASEDIR

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

# quit if script is invoked by template user himself
[ "$USER" = "$TEMPLATE_USER" ] && exit 0

# iterate over profile directories and copy them to users home
for i in $PROFILE_DIRS; do
 [ -e "$HOME/$i" ] || mkdir -p $HOME/$i
	[ -e "$HOME/$i" -a -e "$PROFILE_HOME/$i" ] && rsync -rlpt --inplace --delete --exclude-from /etc/linuxmuster-client/profile.exclude $PROFILE_HOME/$i/ $HOME/$i/
	[ -e "$HOME/$i" ] && chown -R $USER $HOME/$i
done

# link my files folder to desktop
if [ -n "$MYFILES" ]; then
 [ -e "$HOME/$MYFILES" -a ! -d "$HOME/$MYFILES" ] && mv "$HOME/$MYFILES" "$HOME/$MYFILES.BAK"
 if [ ! -e "$HOME/$MYFILES" ]; then
  mkdir -p "$HOME/$MYFILES"
  chown $USER "$HOME/$MYFILES"
 fi
 rm -rf "$HOME/Desktop/$MYFILES"
 ln -s "$HOME/$MYFILES" "$HOME/Desktop/$MYFILES"
 chown $USER "$HOME/Desktop/$MYFILES"
fi

# finally sets permissions for $STUDENTSHOME
if ! check_empty_dir $STUDENTSHOME; then
	chown $ADMINISTRATOR:$TEACHERSGROUP $STUDENTSHOME/*
	chmod 1751 $STUDENTSHOME/*
fi

exit 0

