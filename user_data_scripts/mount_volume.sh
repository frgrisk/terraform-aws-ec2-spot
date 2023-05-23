#!/bin/bash
set -e
set -x
mkfs -t xfs ${device}
mkdir -p ${mount_point}
echo "UUID=$(blkid -o value -s UUID ${device}) ${mount_point} xfs defaults,nofail 0 2" | tee -a /etc/fstab
mount -a
