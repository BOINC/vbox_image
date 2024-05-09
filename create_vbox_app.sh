#!/bin/bash
# this is a very basic script to automatically create an app and submit a WU to your boinc server. I wrote this for testing purposes and it will need some tweaking to be generalized. 
# ths point of this script is to be able to take any vdi and test if it works. You will need to rollback your changes between tests (I do this with Virtualbox snapshots)
# assumes your project directory is at ~/projects/test, that you have a compiled version of boinc in ~/boinc, and that you have a virtualbox guest folder mounted at /mnt/boincserver with your vdi image in it named vm_image_x64_1.vdi
# note you need to create the app in the ops web gui before running this script

cd ~/boinc
git stash
git pull
wget -q https://boinc.berkeley.edu/dl/worker_2_x86_64-pc-linux-gnu
wget https://boinc.berkeley.edu/dl/vboxwrapper_26207_windows_x86_64.exe
# use our special vdi file
echo "copying vdi file"
cp /mnt/boincserver/*.vdi ./vm_image_x64_1.vdi
echo "done copying vdi"
# end of customizations
cd ~/projects/test
mkdir -p apps/worker/1.0/windows_x86_64__vbox_64
cd apps/worker/1.0/windows_x86_64__vbox_64
cp ~/boinc/samples/vboxwrapper/boinc_resolve_1 .
cp ~/boinc/samples/worker/run_worker_1.sh .
cp ~/boinc/samples/worker/vbox_job_worker_1.xml .
cp ~/boinc/samples/worker/vm_version.xml version.xml
cp ~/boinc/worker_2_x86_64-pc-linux-gnu .
# use our vdi instead of guide one
ln -s ~/boinc/vm_image_x64_1.vdi .
#sed -i 's/vm_image_x64_1.vdi/vm_test.vdi/g' vbox_job_worker_1.xml
# back to guide
ln -s ~/boinc/vboxwrapper_26207_windows_x86_64.exe .
cd ~/projects/test
bin/update_versions
cd ~/projects/test/templates
cp ~/boinc/samples/worker/worker_in .
cp ~/boinc/samples/worker/worker_out .
cp /mnt/boincserver/config.xml ~/projects/test/config.xml
cd ~/projects/test
bin/stop
bin/start
echo "tsetSTETtett" > infile
bin/demo_submit worker infile
