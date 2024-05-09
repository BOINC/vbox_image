# boinc_vbox

This repo contains the recipe to create a Virtualbox image that can be used with BOINC. Tested with Debian 12.5 netinstall. Here's how to make it:

1\. Make VM with Virtualbox. Give it like 1GB of RAM, 1 CPU, and say 10GB of disk space. Make a shared folder with folder name "shared" and set it to auto-mount to /root/shared. Set it to boot from the [debian netinstall iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso)

2\. In Debian setup, do Install (not graphical install!). All defaults are fine except:

  2a\. Make hostname boinc, the root pwd boinc and user boinc w/ pwd boinc

  2b\. Remove swap partition during automatic partitioning (guided, use all available space, all in one partition)
  
  2c\. When choosing software to install, unselect all options
  
  2d\. Install bootloader GRUB to main hdd (/dev/sda)
  
3\. Login as root

4\. apt install git

5\. git clone https://github.com/BOINC/vbox_image.git 

6\. cd boinc_vbox

7\. chmod +x *.sh

8\. ./step0.sh

9\. shutdown -r now

10\. Immediately at startup, press esc key to get into grub menu, select advanced options --> recovery mode

11\. In recovery mode run the following commands to zero out free space `echo u > /proc/sysrq-trigger` followed by `zerofree -v /dev/sda1` and `shutdown now`

12\. Finally, clean up the final vmdk image (from the host terminal) `vboxmanage modifyhd FILENAME.vdi --compact`. Note you'll need to find the path to the vdi file for your Virtual Machine and sub it for FILENAME.vdi. You can find this in Virtualbox by clicking on your VM, then Settings -> Storage.

13\. Next time you start the vm, it should create an output file in your shared folder and shut down automatically. This is how you know everything is working. If you need to make edits to the VM, you can rename the boinc_app file from the shared folder, that is the script which triggers the automatic shutdown. Once you move a new executable into its place, it will be run automatically. To prevent automatic run, use `systemctl disable startboincapp.service`

# Use and debugging

This vm expects an executable file to be located at `/root/shared/boinc_app`. If this file exists, it will attempt to execute it and shutdown. If you don't want it to automatically shutdown directly after boot, create a file in the slot directory called `boinc_vm_debug`, this will cause it to wait 10 minutes before shutting down. 

There are two logs created by the launcher, one in the slot directory `launcher_output.txt` (if it is able to mount it), and one in /root. 

# FAQ
#### How does this work under the hood?
The virtualbox contains a systemd unit `/etc/systemd/system/startboincapp.service`. This systemd unit launches a shell script located at `/root/boinc_launcher`. BOINC attempts to mount `/root/shared/` (project slot directory), if it can't do so within two minutes, it shuts down. Otherwise, it launches boinc_app from the slot directory (if it exists), it attempts to execute it, then shuts down the vm. Note that the project directory is not mounted by the launcher, that is handled by the vboxwrapper helper script included with vboxwrapper.

#### My BOINC app needs another version of Debian/Ubuntu/etc, how can I use that?
The setup instructions above should generally work for any version of Debian or Ubuntu. If you hit any snags along the way or find any specific things which must be done for other versions, please let us know.

#### The virtualbox shuts down in < 3 minutes automatically, how can I get in and diagnose it?

If there is no output from your app and the log doesn't show anything, it's probably because the vm is unable to mount the slot directory. You can login to the vm quickly before the 2 minute shutdown timer kicks in (username root, pwd boinc), run `ps -a|grep launcher` to find the launcher script, then `kill pid` with pid being the pid shown by the grep command.

#### The virtualbox shuts down but my app didn't appear to run?

Your boinc_app probably is not marked executable. Check your shared directory for any logs left by the launcher.

### Do I have to use the provided boinc_app shell script?

No, you can use any executable you want as long as it's named boinc_app and placed into the shared directory.
