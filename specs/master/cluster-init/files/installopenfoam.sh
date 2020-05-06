#!/usr/bin/bash
#PBS -j oe
#PBS -l select=1:ncpus=

CUSER=$(cat /mnt/exports/shared/CUSER)
HOMEDIR=/shared/home/${CUSER}
OF_VERSION=$(jetpack config OF_VERSION)

${HOMEDIR}/apps/installOpenFOAM/install.sh ".*OpenFOAM-${OF_VERSION}.*Gcc4_8_5.*" | tee ${HOMEDIR}/logs/log.installOpenFOAM`date "+%Y%m%d_%H%M"`
