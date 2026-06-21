#!/usr/bin/env python
import xarray as xr 
import numpy as np 
import pandas as pd
from datetime import datetime, timedelta
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.models.oceandrift import OceanDrift

#Script for performing simulations seeding on a regular grid

#Readers for winds:
winds2022 = reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_vientosERA5_2022.nc')
winds2023 = reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_vientosERA5_2023.nc')

#Csv for seeding in a regular grid:
seed_file='seed1km_rejillauniforme_55579_339_226.csv'
inputdf=pd.read_csv(seed_file, header=None)
sz=0
nn=55579

LON=np.zeros(nn)
LAT=np.zeros(nn)

for index, column in inputdf.iterrows():
 LON[index]=column[0]
 LAT[index]=column[1]
 sz += 1

#TIMES:
rossby = datetime(2023,3,30, 0,0,0)
huracan = datetime(2022, 11, 1, 0, 0, 0)
junio = datetime(2023, 6, 10, 0, 0, 0)
calma = datetime(2022, 8, 7, 0, 0 , 0) 

#time step should be 300 s,

#CALMA:
#Reader for ocean:
ocean5= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/recortado_OD_5km_calma.nc')
ocean1= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_1km_calma.nc')
sargtime = calma

o = OceanDrift(loglevel=20)
o.add_reader(winds2022)
o.add_reader(ocean5)
o.set_config('general:coastline_action','previous')
o.set_config('drift:advection_scheme', 'runge-kutta')
o.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='calma5km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o)

o1 = OceanDrift(loglevel=20)
o1.add_reader(winds2022)
o1.add_reader(ocean1)
o1.set_config('general:coastline_action','previous')
o1.set_config('drift:advection_scheme', 'runge-kutta')
o1.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o1.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='calma1km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o1)

#HURACAN:
#Reader for ocean:
ocean5= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/recortado_OD_5km_huracan.nc')
ocean1= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_1km_huracan.nc')
sargtime = huracan

o2 = OceanDrift(loglevel=20)
o2.add_reader(winds2022)
o2.add_reader(ocean5)
o2.set_config('general:coastline_action','previous')
o2.set_config('drift:advection_scheme', 'runge-kutta')
o2.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o2.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='huracan5km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o2)

o3 = OceanDrift(loglevel=20)
o3.add_reader(winds2022)
o3.add_reader(ocean1)
o3.set_config('general:coastline_action','previous')
o3.set_config('drift:advection_scheme', 'runge-kutta')
o3.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o3.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='huracan1km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o3)


#ROSSBY:
#Reader for ocean:
ocean5= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/recortado_OD_5km_rossby.nc')
ocean1= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_1km_rossby.nc')
sargtime = rossby

o4 = OceanDrift(loglevel=20)
o4.add_reader(winds2023)
o4.add_reader(ocean5)
o4.set_config('general:coastline_action','previous')
o4.set_config('drift:advection_scheme', 'runge-kutta')
o4.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o4.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='rossby5km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o4)

o5 = OceanDrift(loglevel=20)
o5.add_reader(winds2023)
o5.add_reader(ocean1)
o5.set_config('general:coastline_action','previous')
o5.set_config('drift:advection_scheme', 'runge-kutta')
o5.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o5.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='rossby1km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o5)


#JUNIO:
#Reader for ocean:
ocean5= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/recortado_OD_5km_junio.nc')
ocean1= reader_netCDF_CF_generic.Reader('/home/desan/opendrift/examples/OD_1km_junio.nc')
sargtime = junio

o6 = OceanDrift(loglevel=20)
o6.add_reader(winds2023)
o6.add_reader(ocean5)
o6.set_config('general:coastline_action','previous')
o6.set_config('drift:advection_scheme', 'runge-kutta')
o6.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o6.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='junio5km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o6)

o7 = OceanDrift(loglevel=20)
o7.add_reader(winds2023)
o7.add_reader(ocean1)
o7.set_config('general:coastline_action','previous')
o7.set_config('drift:advection_scheme', 'runge-kutta')
o7.seed_elements(lon=LON, lat=LAT, number=sz, wind_drift_factor=.025, z=0, time=sargtime) 
o7.run(duration=timedelta(days=10), time_step=timedelta(seconds=300), time_step_output=timedelta(hours=12),outfile='junio1km_300s_ftles_55579_30-01-26.nc',export_variables=['time','status','lon','lat'])
print(o7)


