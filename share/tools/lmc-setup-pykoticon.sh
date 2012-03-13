#!/bin/bash
# This script sets up pykoticon to
# do printaccounting with pykota
#
# Frank Schiebel
#
# Install wxgtk as a dep
apt-get install python-wxgtk2.6
# change to source dir
cd /usr/share/linuxmuster-client/pykoticon-1.02/
# install package
python setup.py install
# link icon dirs correctly
if [ -L /usr/share/pykoticon ]; then
    rm /usr/share/pykoticon
fi
ln -s /usr/local/share/pykoticon/ /usr/share/pykoticon
cd


SERVERIP=`grep uri /etc/ldap.conf | grep -v ^# | awk -F"//" '{print $2}' | awk -F"/" '{print $1}'`

(
cat << EOF
[Desktop Entry]
Type=Application
Name=PykotIcon Print-Quota notifier
Exec=/usr/local/bin/pykoticon $SERVERIP
Comment=Show messages from pykota
Icon=folder-remote
Terminal=false
Categories=
OnlyShowIn=GNOME;
X-GNOME-Autostart-Delay=10
EOF
) > /etc/xdg/autostart/pykoticon.desktop
