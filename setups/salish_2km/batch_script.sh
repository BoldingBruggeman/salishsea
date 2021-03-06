#!/bin/bash

#ulimit -s 2097152

#SBATCH --account=def-nereusvc
#SBATCH --job-name=salish_2km
#SBATCH --time=0-02:00

#SBATCH --nodes=1
#SBATCH --ntasks=32
##SBATCH --mem=0

# This gives 64 jobs
##SBATCH --nodes=2
##SBATCH --ntasks-per-node=32
##SBATCH --mem-per-cpu=

export exedir=$HOME/local/intel/17.1/getm/2.1/bin
ln -sf subdomain/par_setup.dat.32 par_setup.dat

salish_setups=$HOME/SalishSea/salishsea/setups
initial_year=2012
final_year=2015
exp=A

start_year=${start_year:-$1}
stop_year=${stop_year:-$2}

if [ $start_year -lt $initial_year ]; then
   start_year=$initial_year
fi
if [ $stop_year -gt $final_year ]; then
   stop_year=$final_year
fi

# default on cedar and graham
basedir=/scratch/$USER/SalishSea
queue_system=1

if [ "$HOSTNAME" == "orca" ]; then 
   basedir=/scratch/$USER/SalishSea
   export exedir=$HOME/local/intel/19.0.0/getm/2.1/bin
   ln -sf subdomain/par_setup.dat.8 par_setup.dat
   queue_system=0
fi

if [ "$HOSTNAME" == "salish-XPS-9100" ]; then 
   basedir=/$HOME/out/SalishSea
   export exedir=$HOME/local/gnu/5/getm/bin
   ln -sf subdomain/par_setup.dat.8 par_setup.dat
   queue_system=0
fi

runid=salish_2km
runscript=$salish_setups/$runid/batch_script.sh
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
