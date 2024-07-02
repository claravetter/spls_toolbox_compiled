#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -o /data/core-psy-pronia/projects/SPLS/$JOB_ID-output-main.txt #output directory
#$ -j y
#$ -N test
#$ -soft -l h_vmem=20
echo '****************************************
echo '*** SPLS           X CORE            ***
echo '****************************************
echo 'export LD_LIBRARY_PATH=/data/core-psy-pronia/opt/matlab/v912/runtime/glnxa64:/data/core-psy-pronia/opt/matlab/v912/bin/glnxa64:/data/core-psy-pronia/opt/matlab/v912/sys/os/glnxa64:/data/core-psy-pronia/opt/matlab/v912/sys/opengl/lib/glnxa64
# Preload glibc_shim in case of RHEL7 variants
# export LD_PRELOAD=/data/core-psy/data/pronia/aruef/matlab_22a_files/glibc-2.17_shim.so
export JOB_DIR=$PWD
SPLS=/data/core-psy-pronia/opt/SPLS_Toolbox_Dev_2023_CORE/

read -e -p 'Path to datafile path ['$datafile']: ' tdatafile '
if [ "$tdatafile" != ' ]; then
        if [ -f $tdatafile ]; then
               export datafile=$tdatafile
        else
                echo $tdatafile' not found.'
             exit
     fi
fi

numCPU=1read -p 'XX GB RAM / SLURM job: ' Memory
MemoryGB=$Memory'GB'

for curCPU in $(seq $((numCPU)))
do
SD='CPU'$curCPU'

SLURMFile=$JOB_DIR/SPLS_$SD.slurm

cat > $SLURMFile <<EOF
#!/bin/sh
#SBATCH --output $JOB_DIR/logs/spls$SD_slurm-%j.log
#SBATCH --error $JOB_DIR/logs/spls$SD_slurm-%j.err
#SBATCH --nodes=1 
#SBATCH --ntasks=1 
#SBATCH --partition jobs-matlab
#SBATCH --account=core-psy
#SBATCH --cpus-per-task=2
#SBATCH --job-name spls$SD
#SBATCH --mem=$MemoryGB

$PMODE
export MCR_CACHE_ROOT=/data/core-psy/opt/temp/$USER
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
cd $SPLS
./SPLS_Dev_2023_COMPILE_R2022a/for_testing/SPLS_Dev_2023_COMPILE_R2022a $datafile
EOF
chmod u+x $SLURMFile
datum=`date +"%Y%m%d"`
if [ -d "$MCR_CACHE_ROOT/.mcrCache9.9" ]; then
rmdir -rf $MCR_CACHE_ROOT/.mcrCache9.9
fi
if [ "$todo" = 'y' -o "$todo" = 'Y' ] ; then
sbatch $SLURMFile >> SPLS_$datum.log
fi
done
