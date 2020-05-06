#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -exuv

SW=openfoam
echo "starting 60.install-${SW}.sh"

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

# get OpenFOAM version
OF_INSTALLATION=$(jetpack config OF_INSTALLATION)
OF_VERSION=$(jetpack config OF_VERSION)

# install OpenFOAM setting or not
if [[ ${OF_VERSION} = None ]] || [[ ${OF_INSTALLATION} = None ]] ; then
   exit 0
fi

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

# download installOpenFOAM script
if [[ ! -f ${HOMEDIR}/apps/installOpenFOAM.tar.gz ]]; then
   wget -nv https://gitlab.com/OpenCAE/installOpenFOAM/-/archive/master/installOpenFOAM-master.tar.gz -O ${HOMEDIR}/apps/installOpenFOAM-master.tar.gz
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/installOpenFOAM-master.tar.gz
fi
if [[ ! -d ${HOMEDIR}/apps/installOpenFOAM ]]; then
   tar zxfp ${HOMEDIR}/apps/installOpenFOAM-master.tar.gz -C ${HOMEDIR}/apps
   mv ${HOMEDIR}/apps/installOpenFOAM-master ${HOMEDIR}/apps/installOpenFOAM
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/installOpenFOAM
fi

cp /mnt/cluster-init/OpenFOAM/master/files/installopenfoam.sh ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh | exit 0
rm -rf ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc.orig | exit 0
mv ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc.orig | exit 0
cp /mnt/cluster-init/OpenFOAM/master/files/ofbashrc ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc | exit 0

# OpenFOAM installation settings
case ${OF_INSTALLATION} in 
   # Master Node Compile
   Compile0 )
      sed -i -e "15c\export WM_NCOMPPROCS=4" ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc
      sed -i -e "3c\#PBS -l select=1:ncpus=4" ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
   ;;
   # Compile1 HC44rs
   Compile1 )
      sed -i -e "15c\export WM_NCOMPPROCS=44" ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc
      sed -i -e "3c\#PBS -l select=1:ncpus=44" ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
      sed -i -e "247c\        OPENMPI_PACKAGE=openmpi-4.0.3" ${HOMEDIR}/apps/installOpenFOAM/etc/version
      sed -i -e "4c\INSTALLOPENFOAM_DIR=$HOME/apps/installOpenFOAM" ${HOMEDIR}/apps/installOpenFOAM/install.sh
   ;;
   # Compile2 HB60rs
   Compile2 )
      sed -i -e "15c\export WM_NCOMPPROCS=60" ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc
      sed -i -e "3c\#PBS -l select=1:ncpus=60" ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
   ;;
   # Compile1 HB120rs_v2
   Compile3 )
      sed -i -e "15c\export WM_NCOMPPROCS=120" ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc
      sed -i -e "3c\#PBS -l select=1:ncpus=120" ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
   ;;
   # Compile1 H16r
   Compile4 )
      sed -i -e "15c\export WM_NCOMPPROCS=16" ${HOMEDIR}/apps/installOpenFOAM/system/default/bashrc
      sed -i -e "3c\#PBS -l select=1:ncpus=16" ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
   ;;
esac

# submit compile job
if [[ ${OF_INSTALLATION} = "Compile0" ]]; then
#   sudo -u ${CUSER} /opt/pbs/bin/qsub -l select=1:vnode=localhost ${HOMEDIR}/apps/installOpenFOAM/system/default/ofjob.sh
   mkdir -p ${HOMEDIR}/download
   chown ${CUSER}:${CUSER} ${HOMEDIR}/download
   sudo -u ${CUSER} bash ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
fi
if [[ ! ${OF_INSTALLATION} = "Compile0" ]]; then
   mkdir -p ${HOMEDIR}/apps/installOpenFOAM/download
   chown -R ${CUSER}:${CUSER} ${HOMEDIR}/apps/installOpenFOAM/download
   sudo -u ${CUSER} /opt/pbs/bin/qsub ${HOMEDIR}/apps/installOpenFOAM/system/default/installopenfoam.sh
fi

if [[ ! -f ${HOMEDIR}/apps/submit_motorbike_job.sh ]]; then
   cp /mnt/cluster-init/OpenFOAM/master/files/submit_motorbike_job.sh ${HOMEDIR}/apps/submit_motorbike_job.sh
   chown ${CUSER}:${CUSER} ${HOMEDIR}/apps/submit_motorbike_job.sh
fi

#clean up
popd
rm -rf $tmpdir


echo "end of 60.install-${SW}.sh"
