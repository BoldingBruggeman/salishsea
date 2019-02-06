#!/bin/bash

exedir=~/local/intel/17.0.3/getm/bin
exedir=~/local/gnu/5/getm/bin
exedir=~/local/gnu/7/getm/bin/

# run spin-up
make namelist runtype=1 hotstart=False start="2015-12-01 00:00:00" stop="2016-01-01 00:00:00" metforcing=False
mpiexec -np 8 $exedir/getm_spherical_parallel
mv salish_2km.2d.????.nc salish_2km.????.stderr HOT/

rename -f 's/\.out$/\.in/' restart.????.out

# run annual tidal simulation
make namelist runtype=1 hotstart=True start="2016-01-01 00:00:00" stop="2017-01-01 00:00:00" metforcing=False
mpiexec -np 8 $exedir/getm_spherical_parallel

# merge result files
ncmerge salish_2km.2d.????.nc salish_2km.2d.nc
