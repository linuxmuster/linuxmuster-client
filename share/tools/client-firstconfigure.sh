#!/bin/bash

# Source config
. /etc/linuxmuster-client/config

if [ "x$TEMPLATE_USER" == "x" ];
    echo "Kein Templatebenutzer gefunden, ist linuxmuster-client korrekt eingerichtet?"
    exit 1
fi

# Automatische Updatecheks deaktivieren: Kein Autostart des Update managers in gnome mehr
if [ -f /etc/xdg/autostart/update-notifier.desktop ]; then
    rm -f /etc/xdg/autostart/update-notifier.desktop
    echo "Deaktiviere automatishe Updatechecks"
    echo "      Lösche /etc/xdg/autostart/update-notifier.desktop"
    echo "erledigt."
    echo
else
    echo "Automatische Updatechecks sind bereits deaktiviert"
fi


# Benutzerliste in gdm deaktivieren
sudo -u gdm gconftool-2 -t bool -s /apps/gdm/simple-greeter/disable_user_list true

# Bildschirmsperre deaktivieren
sudo -u $TEMPLATE_USER gconftool-2 -t bool -s /desktop/gnome/lockdown/disable_lock_screen true
# Benutzer wechsel abschalten
sudo -u $TEMPLATE_USER gconftool-2 -t bool -s /desktop/gnome/lockdown/disable_user_switching true
# Ruhemodi disablen
sed -i 's|<allow_active.*|<allow_active>no</allow_active>|' /usr/share/polkit-1/actions/org.freedesktop.upower.policy
# Benutzeranzeige entfernen
dpkg --remove indicator-me > /dev/null 2>&1

