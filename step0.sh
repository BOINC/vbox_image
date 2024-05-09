#!/bin/bash
# install guest additions
apt update
apt -yy install fasttrack-archive-keyring
add to /etc/apt/sources.list
echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-fasttrack main contrib" >> /etc/apt/sources.list
echo "deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-backports-staging main contrib" >> /etc/apt/sources.list
apt -yy update
apt -yy install virtualbox-guest-utils zerofree
# disable grub boot timeout
sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=2/g' /etc/default/grub
update-grub
apt -yy purge acpi acpid git busybox debconf-i18n eject groff-base iamerican ibritish info ispell laptop-detect logrotate installation-report manpages man-db net-tools os-prober rsyslog tasksel tasksel-data traceroute usbutils wamerican
apt -yy purge linux-headers-*
apt -yy autoremove
apt -yy clean
dpkg --purge `dpkg --get-selections | grep deinstall | cut -f1`
# disable auto fsck at boots
tune2fs -c -1 /dev/sda1
# reinstalling guest utils is needed for auto-mount to work, idk why
apt update
apt install --reinstall virtualbox-guest-utils
# one of the following rm lines broke vbox's auto-mount ability. Disabled for now. 
#rm -r /usr/share/locale/*
#rm -r /usr/share/doc/*
#rm -r /usr/share/man/*
#rm -r /var/log/*
#rm -r /var/cache/debconf/*
#rm -r /var/lib/apt/lists/*
#install auto-start functionality
cp startboincapp.service /etc/systemd/system/
cp boinc_app /root/shared/boinc_app
cp boinc_app_launcher /root
chmod +x /root/boinc_app_launcher
chmod +x /root/shared/boinc_app
systemctl daemon-reload
systemctl enable startboincapp
rm step0.sh
rm README.md
echo "INSTALL COMPLETE"
