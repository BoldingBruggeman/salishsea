#!/bin/bash

#SBATCH --account=def-nereusvc
##SBATCH --nodes=1
##SBATCH --ntasks-per-node=1
##SBATCH --ntasks-per-node=32
#SBATCH --ntasks=1
#SBATCH --mem=100M
##SBATCH --mem=0
##SBATCH --time=0-00:10
##SBATCH --array=1-10%1   # Run a 10-job array, one job at a time.
#SBATCH --job-name=salish_2km
##SBATCH --output=$HOME/scratch/ModelOutPut/Salish500m/GETM500mRun.out
#export exedir=$HOME/local/getm/intel/parallel/16.0.4/bin

salish_setups=$HOME/SalishSea/salishsea/setups
first_year=2010
final_year=2018
exp=A

start_year=${start_year:-$1}
stop_year=${stop_year-$2}

if [ $start_year -le $first_year ]; then
   start_year=$first_year
fi
if [ $stop_year -gt $final_year ]; then
   stop_year=$final_year
fi

# default on cedar and graham
basedir=/scratch/$USER/SalishSea
queue_system=1

if [ "$HOSTNAME" == "orca" ]; then 
   basedir=/scratch/$USER/SalishSea
   queue_system=0
fi

runid=salish_2km
runscript=$salish_setups/$runid/batch_script.sh
export runtype=4
export runtype=1

do_runs=1
do_runs=0

export start="$start_year-01-01 00:00:00"
export stop="$stop_year-01-01 00:00:00"
export out_dir=$basedir/$runid/$runtype/$exp/$start_year
if [ "$start_year" == "$first_year" ]; then
   export hotstart=False
   export temp_method=2
   export salt_method=2
fi
make namelist 

if [ $do_runs == 1 ]; then
   mkdir -p $out_dir
   rm -r $out_dir/*
   if [ $queue_system == 1 ]; then
      srun ~/local/getm/intel/parallel/16.0.4/bin/getm_spherical_parallel
   else
      mpiexec -np 8 $exedir/getm_spherical_parallel
   fi
   mv getm.inp $out_dir/getm.inp
   # prepare hotstart files for next run
   old=`pwd`
   chdir $outdir
   rename -f 's/\.out$/\.in/' restart.????.out
   export next_dir=$basedir/$runid/$runtype/$exp/$stop_year
   mkdir -p $next_dir
   mv restart.????.in $next_dir
   chdir $old
else
   mv getm.inp getm.inp.$start_year
fi

start_year=$stop_year
stop_year=$(( $start_year + 1 ))

if [ "$stop_year" -ge "$final_year" ]; then
   exit 0
fi

if [ "$queue_system" == "0" ]; then
   $0 $start_year $stop_year
fi
if [ "$queue_system" == "1" ]; then
   sbatch $runscript $start_year $stop_year
fi
