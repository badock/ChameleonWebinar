#/bin/bash

HOSTNAME=$(hostname)
UUID=$(uuidgen)

SNAPSHOT_NAME="$HOSTNAME_$UUID"

# Install prerequisite software (only required for XFS file systems, which is the default on CentOS 7):
yum install -y libguestfs-xfs

# Create a tar file of the contents of your instance:
tar cf /tmp/snapshot.tar / --selinux --acls --xattrs --numeric-owner --one-file-system --exclude=/tmp/* --exclude=/proc/* --exclude=/boot/extlinux

# This will take 3 to 5 minutes. Next, convert the tar file into a qcow2 image (if you don't want to use the XFS file system, you can replace xfs by ext4):
virt-make-fs --partition --format=qcow2 --type=xfs --label=img-rootfs /tmp/snapshot.tar /tmp/snapshot.qcow2

#This will take 15 to 20 minutes. The label must match the label used in the image you are snapshotting from. You can find this label in your CentOS instance by running:
ls /dev/disk/by-label

# and looking at the name of the file in that directory. Next ensure that the GRUB bootloader is present in the image:
virt-customize -a /tmp/snapshot.qcow2 --run-command 'grub2-install /dev/sda && grub2-mkconfig -o /boot/grub2/grub.cfg'

# To remove unwanted configuration information from your image, run:
virt-sysprep -a /tmp/snapshot.qcow2

#This command typically runs in less than a minute. To complete the preparation of your snapshot image, create a compressed version of it:
qemu-img convert /tmp/snapshot.qcow2 -O qcow2 /tmp/snapshot_compressed.qcow2 -c
# This will take 4 or 5 minutes to run and will decrease the size of your image on disk by a factor of 5 or more.

# The final steps are to upload your snapshot image to OpenStack Glance. First, visit the Access & Security tab in the OpenStack web interface and "Download OpenStack RC File". Copy this file to your instance and source it. Then simply use the glance client program to upload your image.
#glance image-create --name $SNAPSHOT_NAME --disk-format qcow2 --container-format bare --file /tmp/snapshot_compressed.qcow2

# This command should run relatively quickly.