#!/bin/bash

#SBATCH --account=def-nereusvc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
##SBATCH --ntasks=1
#SBATCH --mem=0
#SBATCH --time=0-00:20
#SBATCH --job-name=salish_2km
##SBATCH --output=$HOME/scratch/ModelOutPut/Salish500m/GETM500mRun.out

export exedir=$HOME/local/intel/17.0.3/getm/bin

salish_setups=$HOME/SalishSea/salishsea/setups
initial_year=2012
final_year=2014
exp=A

read -p "start_year=" start_year
read -p "stop_year=" stop_year
#start_year=${start_year:-$1}
#stop_year=${stop_year:-$2}

if [ $start_year -lt $initial_year ]; then
   start_year=$initial_year
fi
if [ $stop_year -gt $final_year ]; then
   stop_year=$final_year
fi

# default on cedar and graham
basedir=/scratch/$USER/SalishSea
queue_system=1

if [ "$HOSTNAME" == "salish-XPS-9100" ]; then 
   basedir=$HOME/Documents/WorkDocuments/Krishna/GETMoutput
   export exedir=$HOME/local/gnu/5/getm/bin
   ln -sf par_setup.dat.8 par_setup.dat
   queue_system=0
fi

runid=salish_2km
runscript=$salish_setups/$runid/GETMRunscript.sh
export timestep=12
export step_2d=300
export step_3d=7200
export M=10
export bdy3d=True
export meteo_ramp=7200
export river_ramp=7200
export bdy2d_ramp=7200
export bdy3d_ramp=7200
export ip_ramp=7200
#export temp_adv_hor=6
#export temp_adv_ver=6
#export salt_adv_hor=6
#export salt_adv_ver=6


export runtype=4

do_runs=0
do_runs=1

export start="$start_year-01-01 00:00:00"
export stop="$stop_year-01-01 00:00:00"
export out_dir=$basedir/$runid/$runtype/$exp/$start_year
if [ "$start_year" == "$initial_year" ]; then
   export hotstart=False
   export temp_method=3
   export salt_method=3
else
   export hotstart=True
   export temp_method=0
   export salt_method=0
fi
make namelist 

if [ $do_runs == 1 ]; then
   mkdir -p $out_dir
   sed "s#OUTDIR#$out_dir#" output.yaml.in > output.yaml
#KB   rm -r $out_dir/*.{stderr,nc} 
   if [ $queue_system == 1 ]; then
      srun $exedir/getm_spherical_parallel
   else
      mpiexec -np 8 $exedir/getm_spherical_parallel
   fi
   mv getm.inp getm_fabm.inp $out_dir/
   mv $runid.????.stderr $out_dir/
   cp output.yaml $out_dir/
   rm $runid.????.stdout
   # prepare hotstart files for next run
   next_dir=$basedir/$runid/$runtype/$exp/$stop_year
   mkdir -p $next_dir
   mv $out_dir/restart.????.out $next_dir
   for f in $next_dir/*.out; do mv -- "$f" "${f%.out}.in"; done
#   old=`pwd`
#   cd $out_dir
#   mv restart.????.out $next_dir && cd $next_dir && rename out in restart.????.out
#   rename 's/\.out$/\.in/' restart.????.out
#   cd $old
else
   mv getm.inp getm.inp.$start_year
fi

start_year=$stop_year
stop_year=$(( $start_year + 1 ))

if [ "$stop_year" -gt "$final_year" ]; then
   exit 0
fi

if [ "$queue_system" == "0" ]; then
   $0 $start_year $stop_year
fi
if [ "$queue_system" == "1" ]; then
   sbatch $runscript $start_year $stop_year
fi
