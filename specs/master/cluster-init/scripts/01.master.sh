#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 01.master.sh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then 
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/OpenFOAM/master

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# Azure VMs that have ephemeral storage mounted at /mnt/exports.
if [ ! -d ${HOMEDIR}/apps ]; then
   sudo -u ${CUSER} ln -s /mnt/exports/apps ${HOMEDIR}/apps
   chown ${CUSER}:${CUSER} /mnt/exports/apps
fi
chown -R ${CUSER}:${CUSER} /mnt/exports/apps | exit 0

yum install -y htop

# file settings
chown ${CUSER}:${CUSER} ${HOMEDIR}/apps 
mkdir -p ${HOMEDIR}/logs
chown ${CUSER}:${CUSER} ${HOMEDIR}/logs
cp /opt/cycle/jetpack/logs/cluster-init/OpenFOAM/master/scripts/01.master.sh.out ${HOMEDIR}
chown ${CUSER}:${CUSER} ${HOMEDIR}/01.master.sh.out

#clean up
popd
rm -rf $tmpdir


echo "end of 01.master.sh"
