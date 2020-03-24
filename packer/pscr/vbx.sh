#!/bin/sh

sudo yum install gcc make kernel-headers-$(uname -r) kernel-devel-$(uname -r) -y
sudo mount -o loop /home/sdg/VBoxGuestAdditions.iso /mnt
sudo /mnt/VBoxLinuxAdditions.run
sudo umount /mnt
sudo rm -rf VBoxGuestAdditions.iso
sudo yum remove gcc make kernel-devel-$(uname -r) -y