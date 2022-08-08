# Experimental upper sorbian keyboard on [Debian/Ubuntu/Raspberry] Linux

## Apply patches (root access required)

sudo patch -p0 /usr/share/X11/xkb/symbols/de         < usr_share_X11_xkb_symbols_de.patch
sudo patch -p0 /usr/share/X11/xkb/rules/base.lst     < usr_share_X11_xkb_rules_base_lst.patch
sudo patch -p0 /usr/share/X11/xkb/rules/base.xml     < usr_share_X11_xkb_rules_base_xml.patch
sudo patch -p0 /usr/share/X11/xkb/rules/evdev.lst    < usr_share_X11_xkb_rules_evdev_lst.patch
sudo patch -p0 /usr/share/X11/xkb/rules/evdev.xml    < usr_share_X11_xkb_rules_evdev_xml.patch

## Adjust keyboard config

cat etc_default_keyboard

adjust /etc/default/keyboard accordingly

## Apply changes (root access required)

sudo dpkg-reconfigure console-setup
sudo dpkg-reconfigure keyboard-configuration

## After reboot, set keyboard variant manually

setxkbmap -layout de -variant hsb

