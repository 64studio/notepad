# updat
apt-get update
apt-get upgrade
apt-get dist-upgrade

# add user chris
adduser chris
usermod -aG sudo chris
mkdir /home/chris/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhPa8R9jgFJ2gv2bhCBMgEyniBsgyOtAQVm1NiycVEorpQSCBSlaqTy97k3Ro+lSgMuB5VwPZOZoUdawzUokTI+XCg7RZMi8GiTPfdAUr/AlsrVz4lTb3yoyGpIBVNvXAsf4gusHZSVhKQhJR2FfENfizkXSGOxLHbItl+I+GEtjgAdulba3S+Mx+ROhyDu8G6obf+wwqD3a3pg7w0vvReQt3wC0rMNS3voz8BW5OmZc2XZN5IWa9pVEDIKa1jAvE+QKXUAc6mOOGdjxT7+5Q/qV50QVtcEPcOmRJVW3yHhriEvy+OXA1eebUG62nmR+rY72we3Yjgyp20qz+3ILpEw==" > /home/chris/.ssh/authorized_keys
chmod 700 /home/chris/.ssh
chmod 600 /home/chris/.ssh/authorized_keys
chown chris:chris /home/chris/.ssh
chown chris:chris /home/chris/.ssh/authorized_keys

# secure SSH
# edit /etc/ssh/sshd_config
Replace "PermitRootLogin yes" with "PermitRootLogin no"
these are added at the bottom?
ClientAliveInterval 120
PasswordAuthentication no


systemctl restart sshd
exit



# setup the lighttpd server
# login as regular user
# (libterm-readline-gnu-perl is as per Debian bug #866737)

sudo apt-get install lighttpd libterm-readline-gnu-perl
# add any users that will need write access to WWW to the www-data group
sudo chown www-data:www-data -R /var/www/
sudo chmod g+rwxs /var/www/html
sudo usermod -aG www-data chris
sudo lighttpd-enable-mod dir-listing
sudo rm /var/www/html/index.lighttpd.html
echo "Welcome to the 64studio Ltd Debian Stretch build server." | sudo tee -a /var/www/html/README.txt
echo "dir-listing.show-readme = \"enable\"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.set-footer = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.external-js = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
sudo systemctl restart lighttpd



# setup reprepro & pbuilder
# this pulls in a lot of packages. are they all needed?
# qemu-user-static is for other arches (arm etc)

sudo apt-get install reprepro pbuilder ubuntu-dev-tools qemu-user-static
sudo apt-get install git devscripts cdbs

# create pbuilder base images
PBUILDER_RELEASE="stretch"
PBUILDER_ARCHES="amd64 arm64 armel armhf"
for PBUILDER_ARCH in $PBUILDER_ARCHES; do pbuilder-dist $PBUILDER_RELEASE $PBUILDER_ARCH create; done

# make the package
# update pbuilder base images
for PBUILDER_ARCH in $PBUILDER_ARCHES; do pbuilder-dist $PBUILDER_RELEASE $PBUILDER_ARCH updage; done

# build source package
mkdir -p ~/source; cd ~/source
git clone https://github.com/64studio/pdk.git
cd pdk
sudo mk-build-deps -i
dpkg-buildpackage -S -I.git
sudo apt-get purge --auto-remove pdk-build-deps
cd ..

# build binary package for each arch
for PBUILDER_ARCH in $PBUILDER_ARCHES; do pbuilder-dist $PBUILDER_RELEASE $PBUILDER_ARCH build pdk_*.dsc; done

# resuts are here (for stretch...)
ls ~/pbuilder/stretch_result/

