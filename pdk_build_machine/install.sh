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

sudo apt-get install lighttpd
sudo lighttpd-enable-mod dir-listing
sudo rm /var/www/html/index.lighttpd.html
echo "Test!" | sudo tee -a /var/www/html/README.txt
echo "dir-listing.show-readme = \"enable\"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.set-footer = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
echo "dir-listing.external-js = \" \"" | sudo tee -a /etc/lighttpd/conf-enabled/10-dir-listing.conf
sudo systemctl restart lighttpd



# setup reprepro & pbuilder
# this pulls in a lot of packages. are they all needed?

sudo apt-get install reprepro pbuilder ubuntu-dev-tools
