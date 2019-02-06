#!/bin/bash

boundary=savery
boundary=campbell

bathymetry=VIJAYbased
bathymetry=CDObased

ln -sf $bathymetry/topo_2km.nc topo.nc
ln -sf $bathymetry/$boundary/bathymetry.adjust
ln -sf $bathymetry/$boundary/bdyinfo.dat
ln -sf $bathymetry/$boundary/mask.adjust
ln -sf $bathymetry/$boundary/bdy_3d.nc bdy_3d.nc
ln -sf $bathymetry/$boundary/salttemp_init.nc .

met=ecmwf
met=cfsr
ln -sf meteo_files_$met.dat meteo_files.dat
