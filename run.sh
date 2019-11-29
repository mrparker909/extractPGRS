#!/bin/bash

#PBS -N calculatePGRS
#PBS -l mem=10gb
#PBS -l walltime=4:00:00
#PBS -l procs=1
#PBS -o log_$PBS_JOBID.txt
#PBS -e err_$PBS_JOBID.txt

cd ${PBS_O_WORKDIR}
echo "Current working directory is now: " `pwd`
echo "Starting script at `date`"

sh extractPGRS.sh atlasFiles/ binaryFiles/ 0.0000000005 output/

echo "Ending script at `date`"
