#!/bin/bash

ln -sf /home/vijayubc/project/Boundary1km/topo_1km.nc topo.nc
ln -sf /home/vijayubc/project/Boundary1km/bathymetry.adjust
ln -sf /home/vijayubc/project/Boundary1km/bdyinfo.dat
ln -sf /home/vijayubc/project/Boundary1km/mask.adjust
ln -sf /home/vijayubc/project/Boundary1km/bdy_3d.nc bdy_3d.nc
ln -sf /home/vijayubc/project/Boundary1km/bdy_2d.nc bdy_2d.nc
ln -sf /home/vijayubc/project/Boundary1km/salttemp_init.nc salttemp_init.nc
ln -sf /home/vijayubc/project/Boundary1km/riverinfo.dat 
ln -sf /home/vijayubc/project/Rivers/rivers.nc rivers.nc 

met=ecmwf
met=era5_part
met=era5_full
met=cfsr
ln -sf meteo_files_$met.dat meteo_files.dat

