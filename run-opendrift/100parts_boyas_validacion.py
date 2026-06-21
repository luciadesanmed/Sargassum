#!/usr/bin/env python
import xarray as xr 
import numpy as np 
import pandas as pd
import os
from datetime import datetime, timedelta
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.readers import reader_ROMS_native
from opendrift.models.oceandrift import OceanDrift

#codigo para correr las simulaciones con las boyas con lastre
PATH_BOYAS = '/home/desan/opendrift/examples/posicionesboyascsv/'
PATH_CURRENT = '/home/desan/opendrift/examples/corrientes-gfs-boyas-validacion/' 
PATH_WIND = '/home/desan/opendrift/examples/'
PATH_OUTPUT = '/home/desan/opendrift/examples/boyas-validacion/'

# Readers for ROMS currents and ERA5 winds:
corr5km = reader_netCDF_CF_generic.Reader(PATH_CURRENT + '5kmcurrents_buoys_for_opendrift.nc')
corr1km = reader_netCDF_CF_generic.Reader(PATH_CURRENT + '1kmcurrents_buoys_for_opendrift.nc')

winds2022 = reader_netCDF_CF_generic.Reader(PATH_WIND + 'OD_vientosERA5_2022.nc')
winds2023 = reader_netCDF_CF_generic.Reader(PATH_WIND + 'OD_vientosERA5_2023.nc')


################################################################
                #CON LASTRE
################################################################

#BOYA 1:
print('INICIANDO BOYA 1 CON LASTRE')

sargtime = datetime(2023, 3, 2, 0, 0, 0)
final_time = datetime(2023, 3, 11, 6, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya1clastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2023)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya1clastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2023)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya1clastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1

#BOYA 2:
print('INICIANDO BOYA 2 CON LASTRE')

sargtime = datetime(2023, 6, 6, 18, 0, 0)
final_time = datetime(2023, 6, 15, 0, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya2clastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2023)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya2clastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2023)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya2clastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1

################################################################
                #SIN LASTRE
################################################################

#BOYA 1:
print('INICIANDO BOYA 1 SIN LASTRE')

sargtime = datetime(2023, 6, 25, 18, 0, 0)
final_time = datetime(2023, 7, 4, 0, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya1slastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2023)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya1slastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2023)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya1slastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1


#BOYA 2:
print('INICIANDO BOYA 2 SIN LASTRE')

sargtime = datetime(2022, 8, 25, 18, 0, 0)
final_time = datetime(2022, 9, 1, 18, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya2slastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2022)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya2slastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2022)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya2slastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1

#BOYA 3:
print('INICIANDO BOYA 3 SIN LASTRE')

sargtime = datetime(2022, 10, 31, 18, 0, 0)
final_time = datetime(2022, 11, 15, 18, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya3slastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2022)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya3slastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2022)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya3slastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1


#BOYA 4:
print('INICIANDO BOYA 4 SIN LASTRE')

sargtime = datetime(2023, 1, 14, 18, 0, 0)
final_time = datetime(2023, 1, 21, 18, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya4slastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2023)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya4slastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2023)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya4slastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1

#BOYA 5:
print('INICIANDO BOYA 5 SIN LASTRE')

sargtime = datetime(2023, 5, 24, 18, 0, 0)
final_time = datetime(2023, 6, 4, 18, 0, 0)

# Load buoy trajectory
df_boya = pd.read_csv(PATH_BOYAS + 'boya5slastre.csv')

# Simulation Loop:
nn=1
for i, row in df_boya.iloc[::4].iterrows():
    # Calculate the exact time for this specific record (every 6 hours)
    current_seed_time = sargtime + timedelta(hours=6 * i)

    # Ensure the 24-hour simulation does not exceed the final buoy record time
    if current_seed_time + timedelta(hours=24) > final_time:
        print(f"Skipping release {i} at {current_seed_time}: Exceeds final simulation time.")
        break

    lon = row['LON']
    lat = row['LAT']

    print(f"--- Running Release {i} | Time: {current_seed_time} | Lon: {lon}, Lat: {lat} ---")

    # Initialize a fresh model instance for each release
    o = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info
    
    # Add your environmental readers
    o.add_reader(corr5km)
    o.add_reader(winds2023)

    # Configuration
    o.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya5slastre_5km_dia{nn}.nc')

    # 
    o.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

        # Initialize a fresh model instance for each release
    o1 = OceanDrift(loglevel=30)  # loglevel 30 minimizes spam, change to 20 for full info

    # Add your environmental readers
    o1.add_reader(corr1km)
    o1.add_reader(winds2023)

    # Configuration
    o1.set_config('drift:advection_scheme', 'runge-kutta')

    # Seed 11 particles with wind factors from 0 to 0.05
    o1.seed_elements(lon=lon, lat=lat, radius=0, number=100, wind_drift_factor=np.linspace(0, 0.05, 100), z=0, time=current_seed_time
    )

    # Define a distinct output filename for each 24h window
    output_filename = os.path.join(PATH_OUTPUT,f'100part_diario_SK_boya5slastre_1km_dia{nn}.nc')

    # Run for 24 hours, saving history every 30 minutes
    o1.run(
        duration=timedelta(hours=24),
        time_step=300,                           # Internal physics timestep (seconds)
        time_step_output=timedelta(hours=6),  # Write to file every 30 minutes
        outfile=output_filename,
        export_variables=['time', 'status', 'lon', 'lat', 'wind_drift_factor']
    )

    nn=nn+1
