#!/usr/bin/bash 
#PBS -j oe
#PBS -l select=2:ncpus=3

source ~/apps/installOpenFOAM/install.sh -s '.*OpenFOAM-v1906.*Gcc4_8_5.*'

if [[ ! -d ~/apps/motorBike ]]; then
   ~/apps/OpenFOAM/OpenFOAM-v1906/tutorials/incompressible/simpleFoam/motorBike ~/apps/
fi

~/apps/motorBike/Allclean

~/apps/motorBike/Allrun
