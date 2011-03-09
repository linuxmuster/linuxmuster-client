#
# Mount hook for firefox profile
#
# 08.03.2011
# Thomas Schmitt
# Frank Schiebel
#


PROFILE_HOME=$(getent passwd $TEMPLATE_USER | awk -F\: '{ print $6 }')

# create default firefox profile dir if necessary
[ -d $HOME/.mozilla/firefox ] || mkdir -p $HOME/.mozilla/firefox

# create profiles.ini with path to custom profile directory
echo -e "[General]\nStartWithLastProfile=1\n\n[Profile0]\nName=firefox\nIsRelative=1\nPath=../../$APPS_BASEDIR/$FIREFOX_PROFILE\nDefault=1\n\n" > $HOME/.mozilla/firefox/profiles.ini
chown -R $USER $HOME/.mozilla

# create custom firefox profile directory
if [ ! -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ]; then

# copy profile only ifuser is not the template user and ff profile should be copied
if [ "$USER" != "$TEMPLATE_USER"  -a "$FIREFOX" = "yes" ]; then
[ -e "$PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE" ] && cp -a $PROFILE_HOME/$APPS_BASEDIR/$FIREFOX_PROFILE $HOME/$APPS_BASEDIR
fi

# create it if it was not copied
[ -d $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE ] || mkdir $HOME/$APPS_BASEDIR/$FIREFOX_PROFILE

fi

# set permissions
chown -R $USER "$HOME/$APPS_BASEDIR/"

# setting prefs
prefs="$HOME/$APPS_BASEDIR/$FIREFOX_PROFILE/prefs.js"
# delete safebrowsing db
rm "$HOME/$APPS_BASEDIR/$FIREFOX_PROFILE/urlclassifier3.sqlite"
# deleting prefs if exists
sed -i "/browser\.cache\.disk\.capacity/d" $prefs
sed -i "/app\.update\.enabled/d" $prefs
sed -i "/extensions\.update\.enabled/d" $prefs
sed -i "/browser\.search\.update/d" $prefs
sed -i "/browser\.safebrowsing\.enabled/d" $prefs
sed -i "/browser\.safebrowsing\.malware\.enabled/d" $prefs
# setting mandatory default values
echo 'user_pref("browser.cache.disk.capacity",0);' >> $prefs
echo 'user_pref("app.update.enabled",false);' >> $prefs
echo 'user_pref("extensions.update.enabled",false);' >> $prefs
echo 'user_pref("browser.search.update",false);' >> $prefs
echo 'user_pref("browser.safebrowsing.enabled", false);' >> $prefs
echo 'user_pref("browser.safebrowsing.malware.enabled", false);' >> $prefs
