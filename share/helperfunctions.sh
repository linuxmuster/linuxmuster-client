# helperfunctions for linuxmuster bash scripts

# read config vars
. /usr/share/linuxmuster-client/config


# test if string is in string
stringinstring() {
  case "$2" in *$1*) return 0;; esac
  return 1
}


# get user homedir
get_userhome() {
	userhomecache=/tmp/.cache-$USER
	if [ ! -s "$userhomecache" ]; then
		getent passwd $USER | cut -f6 -d: > $userhomecache
		chmod 600 $userhomecache
	fi
	HOME=`cat $userhomecache`
}