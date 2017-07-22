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

# remove the junk
sudo rm /var/www/html/index.lighttpd.html

# directory contents listing
sudo lighttpd-enable-mod dir-listing
echo "Welcome to the 64studio Ltd Debian Stretch build server." | sudo tee -a /var/www/html/README.txt
echo "dir-listing.show-readme = \"enable\"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.hide-readme-file = \"enable\"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.set-footer = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.external-js = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf

# userdir enable
sudo lighttpd-enable-mod userdir

# access log enable
# may be useful for some metrics later; but users' privacy is more important
#sudo lighttpd-enable-mod accesslog

# enable virtualhosts
sudo mkdir /etc/lighttpd/vhosts.d
sudo chown www-data:www-data -R /etc/lighttpd/vhosts.d
echo include_shell \"cat /etc/lighttpd/vhosts.d/*.conf\" | sudo tee -a /etc/lighttpd/lighttpd.conf
# example configuration files:
sudo cat > /etc/lighttpd/vhosts.d/apt.64studio.com.conf <<EOF
$HTTP["host"] =~ "^(www\.)?apt\.64studio\.com" {
    server.document-root = "/var/www/apt"
    accesslog.filename = "/var/log/lighttpd/apt.64studio.com.access.log"
}
EOF
sudo cat > /etc/lighttpd/vhosts.d/pdk.64studio.com.conf <<EOF
$HTTP["host"] =~ "^(www\.)?pdk\.64studio\.com" {
    server.document-root = "/var/www/pdk"
    accesslog.filename = "/var/log/lighttpd/pdk.64studio.com.access.log"
}
EOF

# change document root to /var/www rather than /var/www/html
# i done this on the main server since we haven't yet moved the A records for the subdomains over
# but in practive this would not be needed
#sudo sed -i -e 's|/var/www/html|/var/www|g' /etc/lighttpd/lighttpd.conf
#sudo rm -rf /var/www/cgi-bin
#sudo rm -rf /var/www/html
#sudo mv /var/www/html/README.txt /var/www/README.txt


# restart to apply changes
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

