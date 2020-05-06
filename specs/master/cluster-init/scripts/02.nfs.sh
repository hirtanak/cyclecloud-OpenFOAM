#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

echo "starting 2.nfs.sh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then 
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /mnt/cluster-init/CUSER
HOMEDIR=/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/OpenFOAM/viz

# get palrform
PLATFORM=$(jetpack config platform)
PLATFORM_VERSION=$(jetpack config platform_version)

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir


# anaconda setting
MOUNTPOINT1=$(jetpack config MOUNTPOINT1)
MOUNTPOINT1_KEY=$(jetpack config MOUNTPOINT1_KEY)
yum install -y nfs-utils

set +eu
CMD1=$(mount | grep ${MOUNTPOINT1})
set -eu

if [[ -z "${CMD1}" ]] && [[ ! "${MOUNTPOINT1}" == "None"  ]]; then
   mkdir -p /mnt/${MOUNTPOINT1##*/} 
   mount -o rw,hard,rsize=65536,wsize=65536,vers=3,tcp ${MOUNTPOINT1} /mnt/${MOUNTPOINT1##*/}
fi
set -eu

#clean up
popd
rm -rf $tmpdir


echo "end of 2.nfs.sh"
