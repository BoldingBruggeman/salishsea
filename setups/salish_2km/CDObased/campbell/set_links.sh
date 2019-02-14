#!/bin/bash

ln -sf /home/vijayubc/project/Boundary2km/topo_2km.nc topo.nc
ln -sf /home/vijayubc/project/Boundary2km/bathymetry.adjust
ln -sf /home/vijayubc/project/Boundary2km/bdyinfo.dat
ln -sf /home/vijayubc/project/Boundary2km/mask.adjust
ln -sf /home/vijayubc/project/Boundary2km/bdy_3d.nc bdy_3d.nc
ln -sf /home/vijayubc/project/Boundary2km/bdy_2d.nc bdy_2d.nc
ln -sf /home/vijayubc/project/Boundary2km/salttemp_init.nc salttemp_init.nc
ln -sf /home/vijayubc/project/Boundary2km/riverinfo.dat 
ln -sf /home/vijayubc/project/Rivers/rivers.nc rivers.nc 

met=ecmwf
met=era5_part
met=era5_full
met=cfsr
ln -sf meteo_files_$met.dat meteo_files.dat

