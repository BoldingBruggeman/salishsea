#!/bin/bash

#SBATCH --account=def-nereusvc
#SBATCH --nodes=6
##SBATCH --ntasks-per-node=1
#SBATCH --ntasks-per-node=32
##SBATCH --ntasks=1
##SBATCH --mem=100M
#SBATCH --mem=0
#SBATCH --time=0-02:00
##SBATCH --array=1-10%1   # Run a 10-job array, one job at a time.
#SBATCH --job-name=salish_1km
##SBATCH --output=$HOME/scratch/SalishSea/GETM2kmRun.out
export exedir=$HOME/local/getm/intel/parallel/16.0.4/bin

salish_setups=$HOME/SalishSea/salishsea/setups/TestCase
first_year=2010
final_year=2018
exp=C

start_year=${start_year:-$1}
stop_year=${stop_year-$2}

if [ $start_year -le $first_year ]; then
   start_year=$first_year
fi
if [ $stop_year -gt $final_year ]; then
   stop_year=$final_year
fi

# default on cedar and graham
basedir=/scratch/$USER/ModelOutPut
queue_system=1

if [ "$HOSTNAME" == "orca" ]; then 
   basedir=/scratch/$USER/SalishSea
   queue_system=0
fi

runid=salish_1km
runscript=$salish_setups/$runid/3Dbatch_script.sh
export timestep=6
export step_2d=600
export step_3d=14400
export M=10
export bdy3d=True
export meteo_ramp=14400
export river_ramp=14400
export bdy2d_ramp=14400
export bdy3d_ramp=14400
export ip_ramp=14400
#export meteo_file='meteofiles_ecmwf.dat'
#export temp_adv_hor=6
#export temp_adv_ver=6
#export salt_adv_hor=6
#export salt_adv_ver=6
#export A_const=0.98
#export g1_const=0.85
#export g2_const=73.0

export runtype=1
export runtype=4

do_runs=0
do_runs=1

export start="$start_year-01-01 00:00:00"
export stop="$stop_year-01-01 00:00:00"
export out_dir=$basedir/$runid/$runtype/$exp/$start_year
if [ "$start_year" == "$first_year" ]; then
   export hotstart=False
   export temp_method=3
   export salt_method=3
else
   export hotstart=True
   export temp_method=0
   export salt_method=0
   export in_dir=$out_dir
fi
export z0_const=0.01
make namelist 

if [ $do_runs == 1 ]; then
   mkdir -p $out_dir
   rm -r $out_dir/*.nc
   if [ $queue_system == 1 ]; then
      srun $exedir/getm_spherical_parallel
   else
      mpiexec -np 32 $exedir/getm_spherical_parallel
   fi
   mv getm.inp $out_dir/getm.inp
   mv $runid.????.stderr $out_dir/
   rm $runid.????.stdout
   # prepare hotstart files for next run
   export next_dir=$basedir/$runid/$runtype/$exp/$stop_year
   mkdir -p $next_dir   
   old=`pwd`
   cd $out_dir
   #ncmerge $runid.2d.????.nc $runid.2d$start_year.nc
   #ncmerge $runid.3d.????.nc $runid.3d$start_year.nc
   #rm $runid.2d.????.nc
   #mv $runid.3d.????.nc $next_dir
   mv restart.????.out $next_dir && cd $next_dir && rename out in restart.????.out
   cd $old   
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
